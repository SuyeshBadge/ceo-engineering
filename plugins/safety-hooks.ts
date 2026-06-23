import type { Plugin } from "@opencode-ai/plugin"
import { spawn } from "node:child_process"

const HOOKS_DIR = `${process.env.HOME}/.config/opencode/hooks`

function runHook(script: string, payload: unknown): Promise<string> {
  return new Promise((resolve) => {
    try {
      const child = spawn(`${HOOKS_DIR}/${script}`, {
        shell: false,
        stdio: ["pipe", "pipe", "pipe"],
      })
      let out = ""
      let err = ""
      child.stdout.on("data", (d) => (out += d.toString()))
      child.stderr.on("data", (d) => (err += d.toString()))
      child.on("error", () => resolve(""))
      child.on("close", () => resolve(out + err))
      child.stdin.write(JSON.stringify(payload ?? {}))
      child.stdin.end()
    } catch {
      resolve("")
    }
  })
}

function bashPayload(input: { tool: string }, output: { args?: { command?: string } }) {
  return {
    tool_name: input.tool,
    tool_input: { command: output?.args?.command ?? "" },
    args: { command: output?.args?.command ?? "" },
  }
}

function filePayload(input: { tool: string }, output: { args?: { filePath?: string } }) {
  const filePath = output?.args?.filePath ?? ""
  return {
    tool_name: input.tool,
    tool_input: { file_path: filePath, path: filePath },
    args: { filePath: filePath },
  }
}

export const SafetyHooksPlugin: Plugin = async () => {
  return {
    "tool.execute.before": async (input, output) => {
      const tool = String(input?.tool ?? "").toLowerCase()

      if (tool === "bash" || tool === "shell") {
        const result = await runHook("block-destructive.sh", bashPayload(input, output ?? {}))
        if (result.includes('"permissionDecision": "deny"')) {
          try {
            const parsed = JSON.parse(result)
            const reason = parsed?.hookSpecificOutput?.permissionDecisionReason ?? "blocked by safety hook"
            throw new Error(`[block-destructive] ${reason}`)
          } catch (e) {
            if (e instanceof Error && e.message.startsWith("[block-destructive]")) throw e
            throw new Error(`[block-destructive] command blocked by safety hook`)
          }
        }
        return
      }

      if (tool === "read" || tool === "write" || tool === "edit") {
        const result = await runHook("env-protection.sh", filePayload(input, output ?? {}))
        if (result.includes('"permissionDecision": "deny"')) {
          try {
            const parsed = JSON.parse(result)
            const reason = parsed?.hookSpecificOutput?.permissionDecisionReason ?? "blocked"
            throw new Error(`[env-protection] ${reason}`)
          } catch (e) {
            if (e instanceof Error && e.message.startsWith("[env-protection]")) throw e
            throw new Error(`[env-protection] access blocked by safety hook`)
          }
        }
        return
      }
    },

    "tool.execute.after": async (input, output) => {
      const tool = String(input?.tool ?? "").toLowerCase()
      if (tool === "write" || tool === "edit") {
        await runHook("format-on-save.sh", filePayload(input, output ?? {}))
        await runHook("run-typecheck.sh", filePayload(input, output ?? {}))
      }
    },

    "session.start": async () => {
      await runHook("audit.sh", { event: "session-start" })
    },

    "session.end": async () => {
      await runHook("audit.sh", { event: "session-end" })
    },
  }
}
