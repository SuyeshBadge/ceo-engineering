#!/usr/bin/env bash
# Block destructive commands
# Usage: invoked by opencode safety-hooks plugin on Bash tool
# Exit 0 + JSON permissionDecision: "deny" = block

set -euo pipefail
INPUT=$(cat)

emit_deny() {
  local reason="$1"
  /usr/bin/python3 - "$reason" <<'PY'
import json
import sys

print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": sys.argv[1],
    }
}, separators=(",", ":")))
PY
  exit 0
}

trap 'status=$?; emit_deny "destructive-command hook failed closed at line ${LINENO} (status ${status})"' ERR

set +e
REASON=$(PAYLOAD="$INPUT" /usr/bin/python3 - 2>&1 <<'PY'
import json
import os
import re
import shlex


MAX_DEPTH = 12
DOLLAR_PAREN = chr(36) + chr(40)
SHELLS = {"sh", "bash", "zsh", "dash", "fish", "ksh", "csh", "tcsh"}
INTERPRETERS = {"python", "python3", "node", "nodejs", "ruby", "perl", "php", "osascript", "pwsh", "powershell"}
CONTROL = {";", "&", "&&", "|", "||", "&|", ";;"}
INTERPRETER_SHELL_FRAGMENTS = (
    "os.system(",
    "os.popen(",
    "os.exec",
    "os.remove(",
    "os.rmdir(",
    "os.unlink(",
    "shutil.rmtree(",
    "subprocess.call(",
    "subprocess.run(",
    "subprocess.popen(",
    "subprocess.check_call(",
    "subprocess.check_output(",
    # Bare/aliased subprocess entry points, e.g.
    # `from subprocess import Popen; Popen(['rm','-rf','/'])` — the
    # "subprocess.popen(" fragment above only catches the qualified form.
    "popen(",
    "child_process",
    # Node's fs destructive primitives (fs.rmSync/fs.rm/fs.rmdir/fs.unlink and
    # their promise/aliased/chained forms, e.g.
    # `require('fs').rmSync(...)` or `require('fs').rm(...)`) were previously
    # uncovered — only child_process was checked for Node payloads. The
    # ").rm("-style fragments catch the common one-liner chained-call form
    # (`require('fs').rm(...)`) where no literal "fs." precedes the method,
    # without the false-positive risk of a bare "rm(" fragment (which would
    # also match unrelated calls like "confirm(").
    "fs.rm(",
    "fs.rmdir(",
    "fs.unlink(",
    "rmsync(",
    "rmdirsync(",
    "unlinksync(",
    "promises.rm(",
    ").rm(",
    ").rmdir(",
    ").unlink(",
    "exec(",
    "eval(",
)


def fail(reason: str) -> None:
    print(reason)
    raise SystemExit(2)


def find_command(obj):
    if isinstance(obj, dict):
        for key in ("command", "cmd"):
            value = obj.get(key)
            if isinstance(value, str):
                return value
            if isinstance(value, list) and all(isinstance(item, (str, int, float)) for item in value):
                return shlex.join(str(item) for item in value)
        for value in obj.values():
            found = find_command(value)
            if found:
                return found
    elif isinstance(obj, list):
        for item in obj:
            found = find_command(item)
            if found:
                return found
    return ""


def basename(value: str) -> str:
    return value.rstrip("/").split("/")[-1]


def is_assignment(value: str) -> bool:
    return bool(re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*=.*", value, flags=re.S))


def allowed_env_template(value: str) -> bool:
    base = basename(value.strip("\"'"))
    return base.endswith((".env.example", ".env.sample", ".env.template"))


def protected_secret_path(value: str) -> bool:
    cleaned = value.strip("\"'@,;:()[]{}")
    if not cleaned or cleaned.startswith("-") or allowed_env_template(cleaned):
        return False
    base = basename(cleaned).lower()
    if base == ".env" or base.startswith(".env.") or base.endswith(".env") or ".env." in base:
        return True
    if base in {".npmrc", ".pypirc", ".netrc", "credentials", "credentials.json", "application_default_credentials.json", "id_rsa", "id_ed25519"}:
        return True
    if base.endswith((".pem", ".key", ".p12", ".pfx")):
        return True
    lowered = cleaned.lower()
    return "/.ssh/id_" in lowered or "/.aws/credentials" in lowered or "/.gnupg/" in lowered


def tokenize(text: str):
    try:
        lexer = shlex.shlex(text, posix=True, punctuation_chars=";&|")
        lexer.whitespace_split = True
        lexer.commenters = ""
        return list(lexer)
    except (ValueError, TypeError):
        fail("unable to parse Bash command safely")


def command_groups(tokens):
    groups = []
    current = []
    for token in tokens:
        if token in CONTROL or (token and set(token) <= {";", "&", "|"}):
            if current:
                groups.append(current)
                current = []
        else:
            current.append(token)
    if current:
        groups.append(current)
    return groups


def extract_substitutions(text: str):
    substitutions = []
    index = 0
    while index < len(text):
        if text.startswith(DOLLAR_PAREN, index):
            depth = 1
            cursor = index + 2
            while cursor < len(text) and depth:
                if text.startswith(DOLLAR_PAREN, cursor):
                    depth += 1
                    cursor += 2
                    continue
                if text[cursor] == ")":
                    depth -= 1
                    if depth == 0:
                        substitutions.append(text[index + 2:cursor])
                        break
                cursor += 1
            if depth:
                fail("unable to parse command substitution safely")
            index = cursor + 1
            continue
        if text[index] == chr(96):
            cursor = index + 1
            while cursor < len(text) and text[cursor] != chr(96):
                cursor += 1
            if cursor >= len(text):
                fail("unable to parse backtick substitution safely")
            substitutions.append(text[index + 1:cursor])
            index = cursor + 1
            continue
        index += 1
    return substitutions


def has_recursive_force(options) -> bool:
    recursive = any(option in {"-r", "-R", "--recursive"} or (option.startswith("-") and "r" in option.lower()[1:]) for option in options)
    forced = any(option in {"-f", "--force"} or (option.startswith("-") and "f" in option.lower()[1:]) for option in options)
    return recursive and forced


def unbounded_target(target: str) -> bool:
    cleaned = target.strip("\"'").rstrip("/") or "/"
    return cleaned in {"/", ".", "..", "~", "$HOME", "${HOME}", "*", "./*", "../*", "~/*", "$HOME/*", "${HOME}/*"} or cleaned.startswith("/Users/*")


def check_always_blocked(text: str, tokens) -> None:
    lowered = text.lower()
    if re.search(r":\s*\(\s*\)\s*\{\s*:\s*\|\s*:\s*&\s*\}\s*;", text):
        fail("fork bombs are never allowed")
    if re.search(r"(?<![\w-])(?:mkfs(?:\.[\w-]+)?|fdisk|parted)\b", lowered):
        fail("filesystem and partition destruction is blocked")
    if re.search(r"(?<![\w-])dd\b[^;&|]*(?:of\s*=\s*)/dev/", lowered):
        fail("raw disk writes are blocked")
    if re.search(r"(?<![\w-])diskutil\s+(?:erase|partition|apfs\s+delete)", lowered):
        fail("disk destruction is blocked")
    if re.search(r"(?<![\w-])(?:shutdown|reboot|halt|poweroff)\b", lowered):
        fail("system shutdown is blocked")
    if re.search(r"(?<![\w-])kill\s+(?:-[a-z]*9[a-z]*\s+)?-1\b", lowered) or re.search(r"(?<![\w-])(?:killall|pkill)\s+-(?:9|kill)\b", lowered):
        fail("process-table destruction is blocked")
    if re.search(r"(?<![\w-])(?:systemctl|launchctl)\s+(?:disable|mask|stop|unload|bootout)\b", lowered):
        fail("system service destruction is blocked")
    if re.search(r"(?<![\w-])git\s+reset\b[^;&|]*--hard\b", lowered):
        fail("git reset --hard destroys uncommitted work")
    if re.search(r"(?<![\w-])git\s+clean\b[^;&|]*-[a-z]*f", lowered):
        fail("git clean -f deletes untracked files")
    if re.search(r"(?<![\w-])git\s+push\b[^;&|]*(?:--force(?:-with-lease)?(?:=\S+)?|(?:^|\s)-[a-z]*f)", lowered):
        fail("force push is never allowed")
    if re.search(r"(?<![\w-])git\s+push\b[^;&|\n]*\s(?:\S*:)?\+[^\s;&|]+", text):
        fail("forced push refspecs are never allowed")
    if re.search(r"(?<![\w-])(?:curl|wget)\b[^;&|]*\|\s*(?:sudo\s+)?(?:ba|z|fi)?sh\b", lowered):
        fail("pipe-to-shell execution is blocked")
    if re.search(r"(?<![\w-])gh\s+auth\s+token\b", lowered) or re.search(r"(?<![\w-])gcloud\s+auth\s+print-(?:access|identity)-token\b", lowered):
        fail("credential token reads are blocked")
    if re.search(r"(?<![\w-])(?:printenv|export\s+-p)\b", lowered) or re.fullmatch(r"\s*(?:env|set)\s*", lowered):
        fail("bulk environment and secret reads are blocked")
    if re.search(r"(?<![\w-])(?:security\s+find-[\w-]*password|op\s+(?:read|get)|pass\s+show|kubectl\s+config\s+view[^;&|]*--raw)", lowered):
        fail("credential-store reads are blocked")
    if re.search(
        r"(?:curl|wget|nc|ncat|scp|rsync)\b[^;&|]*(?:\$"
        r"(?:\{)?(?:[A-Z0-9_]*(?:TOKEN|SECRET|PASSWORD|API_KEY|PRIVATE_KEY))[A-Z0-9_]*\}?|@?[^\s;&|]*(?:\.env(?:\.[^\s;&|]+)?|id_rsa|id_ed25519|\.pem|\.key))",
        text,
        flags=re.I,
    ):
        fail("secret exfiltration is blocked")
    for token in tokens:
        if protected_secret_path(token):
            fail("reading, writing, or exposing secret files is blocked")
    for match in re.finditer(r"(?<![<>])(?:\d+|&)?>>?\s*([^\s;|&<>]+)|(?<![<>])<\s*([^\s;|&<>]+)", text):
        if protected_secret_path(match.group(1) or match.group(2) or ""):
            fail("shell redirection involving secret files is blocked")


GH_META_REJECT = (chr(96), chr(36), "(", ")", "<", ">", "|", ";", "&", "\\", "\n", "\r", "\t")


def _safe_tokens(text):
    try:
        lexer = shlex.shlex(text, posix=True, punctuation_chars=";&|")
        lexer.whitespace_split = True
        lexer.commenters = ""
        return list(lexer)
    except (ValueError, TypeError):
        return None


def _valid_owner_repo(seg, placeholder):
    if seg == placeholder:
        return True
    if seg in (".", ".."):
        return False
    return bool(re.fullmatch(r"[A-Za-z0-9._-]+", seg))


def _valid_reply_endpoint(tok):
    if not tok or "://" in tok or "%" in tok or ".." in tok:
        return False
    path = tok[1:] if tok.startswith("/") else tok
    segs = path.split("/")
    if len(segs) != 8 or any(s == "" for s in segs):
        return False
    repos, owner, repo, pulls, num, comments, cid, replies = segs
    if (repos, pulls, comments, replies) != ("repos", "pulls", "comments", "replies"):
        return False
    if not _valid_owner_repo(owner, "{owner}") or not _valid_owner_repo(repo, "{repo}"):
        return False
    return bool(re.fullmatch(r"[0-9]+", num)) and bool(re.fullmatch(r"[0-9]+", cid))


def _valid_body_file(f):
    if not f or f in ("-", "@-") or f.startswith("-"):
        return False
    if "%" in f or ".." in f:
        return False
    low = f.lower()
    if low.startswith(("/dev/fd/", "/proc/self/fd/")) or re.match(r"/proc/\d+/fd/", low):
        return False
    if low in ("/dev/stdin", "/dev/stdout", "/dev/stderr"):
        return False
    # The reply body is published publicly on GitHub, so this file argument
    # is an exfiltration vector distinct from ordinary redirects: block the
    # same secret-path patterns as everywhere else in this hook, plus the
    # system/credential directories protected_secret_path() doesn't cover
    # (it only matches specific basenames/`.aws/credentials`, not e.g.
    # /etc/passwd, /proc/*/environ, or the rest of ~/.aws or ~/.kube).
    if low.startswith(("/proc/", "/sys/", "/etc/", "/private/etc/")):
        return False
    if protected_secret_path(f) or any(
        marker in low for marker in ("/.aws/", "/.kube/", "/.docker/", "/.gnupg/", "/.ssh/", "/.pgpass")
    ):
        return False
    return bool(re.fullmatch(r"[A-Za-z0-9._/-]+", f))


def gh_pr_reply_allowed(text):
    if any(ch in text for ch in GH_META_REJECT):
        return False
    tokens = _safe_tokens(text)
    if not tokens or len(tokens) < 3:
        return False
    if tokens[0] != "gh" or tokens[1] != "api":
        return False
    method = body = endpoint = 0
    i, n = 2, len(tokens)
    while i < n:
        t = tokens[i]
        if t in ("-X", "--method"):
            if i + 1 >= n or tokens[i + 1] != "POST":
                return False
            method += 1; i += 2; continue
        if t.startswith("--method="):
            if t[len("--method="):] != "POST":
                return False
            method += 1; i += 1; continue
        if t in ("-F", "--field"):
            if i + 1 >= n or not tokens[i + 1].startswith("body=@") \
               or not _valid_body_file(tokens[i + 1][len("body=@"):]):
                return False
            body += 1; i += 2; continue
        if t.startswith("--field="):
            v = t[len("--field="):]
            if not v.startswith("body=@") or not _valid_body_file(v[len("body=@"):]):
                return False
            body += 1; i += 1; continue
        if t == "--input":
            if i + 1 >= n or not _valid_body_file(tokens[i + 1]):
                return False
            body += 1; i += 2; continue
        if t.startswith("--input="):
            if not _valid_body_file(t[len("--input="):]):
                return False
            body += 1; i += 1; continue
        if t.startswith("-"):
            return False
        endpoint += 1
        if endpoint > 1 or not _valid_reply_endpoint(t):
            return False
        i += 1
    return method == 1 and body == 1 and endpoint == 1


def restricted_operation(text, allow_carveout=True):
    if allow_carveout and gh_pr_reply_allowed(text):
        return None
    lowered = text.lower()
    patterns = [
        (r"(?<![\w-])npm\s+(?:i|install|ci|uninstall|remove|update)\b", "dependency changes require CEO/user approval and DevOps routing"),
        (r"(?<![\w-])pnpm\s+(?:i|install|add|remove|update|up|dlx)\b", "dependency changes require CEO/user approval and DevOps routing"),
        (r"(?<![\w-])yarn\s+(?:install|add|remove|up|upgrade|dlx)\b", "dependency changes require CEO/user approval and DevOps routing"),
        (r"(?<![\w-])bun\s+(?:install|add|remove|update|x)\b", "dependency changes require CEO/user approval and DevOps routing"),
        (r"(?<![\w-])(?:pip|pip3|uv|poetry|gem|composer|cargo)\s+(?:install|uninstall|add|remove|update|sync|require)\b", "dependency changes require CEO/user approval and DevOps routing"),
        (r"(?<![\w-])go\s+get\b", "dependency changes require CEO/user approval and DevOps routing"),
        (r"(?<![\w-])(?:npm\s+(?:publish|unpublish|deprecate)|pnpm\s+publish|yarn\s+npm\s+publish|bun\s+publish|cargo\s+(?:publish|yank)|twine\s+upload|gem\s+push)\b", "package publication requires approved DevOps execution"),
        (r"(?<![\w-])(?:vercel|netlify|flyctl|railway|firebase)\s+(?:deploy|up|release)\b", "deployment requires approved DevOps execution"),
        (r"(?<![\w-])(?:wrangler\s+deploy|gcloud\s+app\s+deploy|docker\s+push|helm\s+(?:install|upgrade|uninstall)|gh\s+release\s+(?:create|delete|edit|upload))\b", "publication or deployment requires approved DevOps execution"),
        (r"(?<![\w-])git\s+(?:merge|rebase|tag|cherry-pick|revert)\b", "Git history-rewriting operations require direct human execution"),
        (r"(?<![\w-])(?:terraform|tofu)\s+(?:apply|destroy|import|state\s+(?:mv|rm|push)|workspace\s+(?:delete|new))\b", "infrastructure mutation requires approved DevOps execution"),
        (r"(?<![\w-])pulumi\s+(?:up|destroy|stack\s+rm)\b", "infrastructure mutation requires approved DevOps execution"),
        (r"(?<![\w-])kubectl\s+(?:delete|apply|create|replace|patch|edit|scale|rollout|drain|cordon|taint)\b", "Kubernetes mutation requires approved DevOps execution"),
        (r"(?<![\w-])(?:aws|gcloud|az)\b[^;&|]*(?:delete|destroy|remove|rm|terminate|deploy|create|update|put|set|write)\b", "cloud mutation requires approved DevOps execution"),
        (r"(?<![\w-])(?:psql|mysql|sqlite3|mongosh?|redis-cli)\b[^;&|]*(?:drop\s+(?:database|schema|table)|truncate\s+table|delete\s+from|flushall|flushdb)\b", "destructive database operation requires approved DevOps execution"),
        (r"(?<![\w-])gh\s+issue\s+(?:create|edit|delete|close|reopen|merge|review|run|enable|disable|dispatch)\b", "This GitHub write requires direct human execution"),
        (r"(?<![\w-])gh\s+(?:repo|workflow|release)\s+(?:create|edit|delete|close|reopen|merge|comment|review|run|enable|disable|dispatch)\b", "This GitHub write requires direct human execution"),
        (r"(?<![\w-])gh\s+pr\s+(?:edit|delete|close|reopen|merge|review|ready|lock|unlock)\b", "This GitHub write requires direct human execution"),
        # gh api implicit-write detection: -f/-F/--field/--raw-field/--input
        # imply a write (gh api auto-promotes GET to POST once any field flag
        # is present, even with no explicit -X/--method), and a GraphQL
        # mutation via the generic `gh api graphql` endpoint is a write too —
        # both were previously missed by the explicit-method-only check below.
        (r"(?<![\w-])gh\s+api\b[^;&|]*\s(?:-f|-F|--field|--raw-field|--input)\b", "This GitHub API write requires direct human execution"),
        (r"(?<![\w-])gh\s+api\b[^;&|]*\bgraphql\b[^;&|]*\bmutation\b", "This GitHub API write requires direct human execution"),
        (r"(?<![\w-])gh\s+api\b[^;&|]*\bmutation\b[^;&|]*\bgraphql\b", "This GitHub API write requires direct human execution"),
        (r"(?<![\w-])gh\s+api\b[^;&|]*(?:-X|--method)\s*(?:POST|PUT|PATCH|DELETE)\b", "This GitHub API write requires direct human execution"),
        (r"(?<![\w-])curl\b[^;&|]*(?:(?:-X|--request)\s*(?:POST|PUT|PATCH|DELETE)\b|(?:-d|--data(?:-binary|-raw|-urlencode)?|-[fT]|--form|--upload-file)(?:\s|=))", "HTTP writes require approved DevOps execution"),
        (r"(?<![\w-])wget\b[^;&|]*(?:--post-data|--post-file|--method\s*=\s*(?:POST|PUT|PATCH|DELETE))", "HTTP writes require approved DevOps execution"),
        (r"(?<![\w-])(?:ssh|scp|sftp|nc|ncat|telnet)\b", "remote writes require approved DevOps execution"),
    ]
    for pattern, reason in patterns:
        if re.search(pattern, lowered, flags=re.I):
            return reason
    if re.search(r"(?<![\w-])rsync\b[^;&|]*\s\S+:[^\s]+", text):
        return "remote writes require approved DevOps execution"
    return None


def check_interpreter_payload(text: str) -> None:
    # Inline interpreter code (python3 -c, node -e, ...) is source in another
    # language, not shell syntax — do NOT re-tokenize it with shlex (that is
    # what let `python3 -c "import os; os.system('rm -rf /')"` slip through
    # previously). Instead, scan the raw payload text as a plain string for
    # the same destructive patterns already enforced elsewhere, plus a
    # rm -rf-style regex and known-dangerous shell-out/filesystem call
    # fragments.
    check_always_blocked(text, [])
    reason = restricted_operation(text, allow_carveout=False)
    if reason:
        fail(reason)
    lowered = text.lower()
    if re.search(r"rm\s+(?:-\S+\s+)*-[a-z]*r[a-z]*f[a-z]*\b", lowered) or re.search(
        r"rm\s+(?:-\S+\s+)*-[a-z]*f[a-z]*r[a-z]*\b", lowered
    ):
        fail("interpreter payload attempts an unbounded rm -rf")
    if any(fragment in lowered for fragment in INTERPRETER_SHELL_FRAGMENTS):
        fail("interpreter payload invokes a shell/process/filesystem primitive that bypasses static command inspection")


def unwrap(tokens, depth: int) -> None:
    while tokens and is_assignment(tokens[0]):
        tokens = tokens[1:]
    if not tokens:
        return
    executable = basename(tokens[0]).lower()
    if executable in {"command", "exec", "nohup", "time"}:
        rest = [token for token in tokens[1:] if not token.startswith("-")]
        if rest:
            inspect_tokens(rest, depth + 1)
        return
    if executable == "sudo":
        index = 1
        while index < len(tokens) and tokens[index].startswith("-"):
            option = tokens[index]
            index += 1
            if option in {"-u", "--user", "-g", "--group", "-h", "--host"} and index < len(tokens):
                index += 1
        inspect_tokens(tokens[index:], depth + 1)
        return
    if executable == "env":
        index = 1
        while index < len(tokens) and (tokens[index].startswith("-") or is_assignment(tokens[index])):
            index += 1
        inspect_tokens(tokens[index:], depth + 1)
        return
    if executable in SHELLS:
        for index, token in enumerate(tokens[1:], start=1):
            if token == "-c" or (token.startswith("-") and "c" in token[1:]):
                if index + 1 >= len(tokens):
                    fail("nested shell command is missing its command text")
                inspect_text(tokens[index + 1], depth + 1)
                return
        return
    if executable in INTERPRETERS:
        code_flags = {"-c"} if executable.startswith("python") else {"-e", "--eval", "-c", "-command"}
        for index, token in enumerate(tokens[1:], start=1):
            if token.lower() in code_flags:
                if index + 1 >= len(tokens):
                    fail("interpreter command is missing its code")
                check_interpreter_payload(tokens[index + 1])
                return
        return


def inspect_tokens(tokens, depth: int) -> None:
    if depth > MAX_DEPTH:
        fail("nested command inspection depth exceeded")
    if not tokens:
        return
    text = shlex.join(tokens)
    check_always_blocked(text, tokens)
    reason = restricted_operation(text)
    if reason:
        fail(reason)
    executable_index = 0
    while executable_index < len(tokens) and is_assignment(tokens[executable_index]):
        executable_index += 1
    if executable_index >= len(tokens):
        return
    executable = basename(tokens[executable_index]).lower()
    command_tokens = tokens[executable_index:]
    if executable == "rm":
        options = [token for token in command_tokens[1:] if token.startswith("-")]
        targets = [token for token in command_tokens[1:] if not token.startswith("-")]
        if has_recursive_force(options) and any(unbounded_target(target) for target in targets):
            fail("unbounded rm -rf is never allowed")
    if executable == "find" and "-delete" in command_tokens:
        roots = [token for token in command_tokens[1:] if not token.startswith("-")]
        if not roots or unbounded_target(roots[0]):
            fail("unbounded find -delete is blocked")
    unwrap(command_tokens, depth)


def inspect_text(text: str, depth: int = 0) -> None:
    if depth > MAX_DEPTH:
        fail("nested command inspection depth exceeded")
    if not isinstance(text, str) or not text.strip():
        fail("missing Bash command in hook payload")
    tokens = tokenize(text)
    if not tokens:
        fail("missing Bash executable")
    check_always_blocked(text, tokens)
    reason = restricted_operation(text)
    if reason:
        fail(reason)
    for substitution in extract_substitutions(text):
        inspect_text(substitution, depth + 1)
    for group in command_groups(tokens):
        inspect_tokens(group, depth + 1)


payload_text = os.environ.get("PAYLOAD", "")
try:
    payload = json.loads(payload_text)
except Exception:
    fail("malformed Bash hook payload")
if not isinstance(payload, dict):
    fail("malformed Bash hook payload")

command = find_command(payload.get("tool_input", payload))
inspect_text(command.strip() if isinstance(command, str) else "")
raise SystemExit(0)
PY
)
STATUS=$?
set -e

if [[ $STATUS -eq 2 ]]; then
  emit_deny "$REASON"
elif [[ $STATUS -ne 0 ]]; then
  emit_deny "unable to inspect Bash command safely: ${REASON:-unknown parser failure}"
fi

# Nothing blocked — exit 0 silently
exit 0
