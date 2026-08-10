import type { Plugin } from "@opencode-ai/plugin"

const HOOKS_DIR = decodeURIComponent(new URL("../hooks/", import.meta.url).pathname)
const AUDIT_LOG_DIR = decodeURIComponent(new URL("../../opencode-audit/", import.meta.url).pathname)

type Shell = Parameters<Plugin>[0]["$"]

type HookResult = {
  stdout: string
  stderr: string
  exitCode: number | null
  error?: string
}

async function runHook($: Shell, script: string, payload: unknown, environment?: Record<string, string>): Promise<HookResult> {
  try {
    const command = $`printf %s ${JSON.stringify(payload ?? {})} | ${`${HOOKS_DIR}${script}`}`.quiet().nothrow()
    if (environment) command.env(environment)
    const result = await command
    return {
      stdout: result.stdout.toString(),
      stderr: result.stderr.toString(),
      exitCode: result.exitCode,
    }
  } catch (error) {
    return {
      stdout: "",
      stderr: "",
      exitCode: null,
      error: error instanceof Error ? error.message : "unknown hook error",
    }
  }
}

async function logDenial($: Shell, label: string, reason: string, sessionID: string | undefined, denialPayload: Record<string, unknown>): Promise<void> {
  await runHook(
    $,
    "audit.sh",
    {
      event: `${label}.denied`,
      session_id: sessionID,
      reason,
      ...denialPayload,
    },
    { CEO_AUDIT_LOG: AUDIT_LOG_DIR },
  )
}

async function enforceSafetyHook(
  $: Shell,
  result: HookResult,
  label: string,
  sessionID: string | undefined,
  denialPayload: Record<string, unknown>,
): Promise<void> {
  if (result.error || result.exitCode !== 0) {
    await logDenial($, label, "safety hook failed closed", sessionID, denialPayload)
    throw new Error(`[${label}] safety hook failed closed`)
  }

  const output = `${result.stdout}${result.stderr}`.trim()
  if (!output) return

  let parsed: unknown
  try {
    parsed = JSON.parse(output)
  } catch {
    await logDenial($, label, "malformed safety hook output; failed closed", sessionID, denialPayload)
    throw new Error(`[${label}] malformed safety hook output; failed closed`)
  }

  const hookOutput = (parsed as { hookSpecificOutput?: { permissionDecision?: string; permissionDecisionReason?: string } })
    ?.hookSpecificOutput
  if (hookOutput?.permissionDecision === "deny") {
    const reason = hookOutput.permissionDecisionReason ?? "blocked by safety hook"
    await logDenial($, label, reason, sessionID, denialPayload)
    throw new Error(`[${label}] ${reason}`)
  }

  await logDenial($, label, "unexpected non-deny safety hook output; failed closed", sessionID, denialPayload)
  throw new Error(`[${label}] unexpected non-deny safety hook output; failed closed`)
}

function bashPayload(input: { tool: string }, output: { args?: { command?: string } }) {
  return {
    tool_name: input.tool,
    tool_input: { command: output?.args?.command ?? "" },
    args: { command: output?.args?.command ?? "" },
  }
}

type FileToolArgs = {
  filePath?: string
  path?: string
}

function filePayload(tool: string, args: FileToolArgs | undefined) {
  const filePath = args?.filePath ?? args?.path ?? ""
  return {
    tool_name: tool,
    tool_input: { file_path: filePath, path: filePath },
    args: { filePath: filePath },
  }
}

type TaskToolArgs = {
  subagent_type?: string
  subagentType?: string
  description?: string
  prompt?: string
}

function taskPayload(input: { tool: string }, args: TaskToolArgs | undefined) {
  const subagentType = args?.subagent_type ?? args?.subagentType ?? ""
  const description = args?.description ?? ""
  const prompt = args?.prompt ?? ""
  return {
    tool_name: input.tool,
    tool_input: { subagent_type: subagentType, description, prompt },
    args: { subagent_type: subagentType, description, prompt },
  }
}

export const SafetyHooksPlugin: Plugin = async ({ $ }) => {
  return {
    "tool.execute.before": async (input, output) => {
      const tool = String(input?.tool ?? "").toLowerCase()

      if (tool === "bash" || tool === "shell") {
        const payload = bashPayload(input, output ?? {})
        const result = await runHook($, "block-destructive.sh", payload)
        await enforceSafetyHook($, result, "block-destructive", input.sessionID, payload)
        return
      }

      if (tool === "read" || tool === "write" || tool === "edit") {
        const payload = filePayload(input.tool, output.args as FileToolArgs | undefined)
        const result = await runHook($, "env-protection.sh", payload)
        await enforceSafetyHook($, result, "env-protection", input.sessionID, payload)
        return
      }

      if (tool === "task") {
        const payload = taskPayload(input, output?.args as TaskToolArgs | undefined)
        const result = await runHook($, "guard-readonly-builder.sh", payload)
        await enforceSafetyHook($, result, "guard-readonly-builder", input.sessionID, payload)
        return
      }
    },

    "tool.execute.after": async (input) => {
      const tool = String(input.tool ?? "").toLowerCase()
      if (tool === "write" || tool === "edit") {
        await runHook(
          $,
          "audit.sh",
          {
            event: "tool.execute.after",
            session_id: input.sessionID,
            ...filePayload(input.tool, input.args as FileToolArgs | undefined),
          },
          { CEO_AUDIT_LOG: AUDIT_LOG_DIR },
        )
      }
    },

    event: async ({ event }) => {
      if (event.type === "session.created" || event.type === "session.idle") {
        await runHook($, "audit.sh", { event: event.type, properties: event.properties }, { CEO_AUDIT_LOG: AUDIT_LOG_DIR })
      }
    },
  }
}
