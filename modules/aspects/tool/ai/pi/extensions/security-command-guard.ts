import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const reason = "security CLI is forbidden. Ask the user to run it outside Pi.";

// shortcut: checks command text only; use a sandbox for calls hidden inside scripts.
// Block quoted mentions too rather than treating shell quoting as safe.
function mentionsSecurity(command: string): boolean {
  return /\bsecurity\b/.test(command);
}

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", (event) => {
    if (event.toolName !== "bash") return;
    const command = event.input.command;
    if (typeof command === "string" && mentionsSecurity(command)) {
      return { block: true, reason };
    }
  });

  pi.on("user_bash", (event) => {
    if (!mentionsSecurity(event.command)) return;
    return {
      result: {
        output: reason,
        exitCode: 1,
        cancelled: false,
        truncated: false,
      },
    };
  });
}
