import assert from "node:assert/strict";
import test from "node:test";
import registerGuard from "../../modules/aspects/tool/ai/pi/extensions/security-command-guard.ts";

function handlers() {
  const registered = new Map();
  registerGuard({ on: (name, handler) => registered.set(name, handler) });
  return registered;
}

test("rejects agent shell calls without executing them", async () => {
  const guard = handlers().get("tool_call");
  for (const command of [
    "security",
    "security dump-keychain",
    "security delete-generic-password",
    "/usr/bin/security find-generic-password -w",
    "TOKEN=$(security find-internet-password -w)",
    "security dump-keychain | grep jira",
    "bash -c '/usr/bin/security dump-keychain'",
    "sudo security dump-keychain",
    "env /usr/bin/security dump-keychain",
    "git status\nsecurity dump-keychain",
    'echo "security dump-keychain"',
  ]) {
    const result = await guard({ toolName: "bash", input: { command } });
    assert.equal(result?.block, true, command);
  }
  assert.equal(await guard({ toolName: "bash", input: { command: "git status" } }), undefined);
  assert.equal(await guard({ toolName: "read", input: { path: "security.md" } }), undefined);
  const nestedResult = await guard({
    toolName: "bash",
    parentToolCallId: "codemode-call",
    input: { command: "/usr/bin/security dump-keychain" },
  });
  assert.equal(nestedResult.block, true);
});

test("rejects user shell commands without executing them", async () => {
  const guard = handlers().get("user_bash");
  for (const excludeFromContext of [false, true]) {
    const result = await guard({ command: "security dump-keychain", excludeFromContext });
    assert.equal(result?.result.exitCode, 1);
    assert.match(result.result.output, /forbidden/);
  }
  assert.equal(await guard({ command: "git status" }), undefined);
});
