import { execFileSync } from "node:child_process";
import {
  Action,
  ActionPanel,
  closeMainWindow,
  Form,
  showToast,
  Toast,
} from "@vicinae/api";
import { useState } from "react";
import { focusTerminalApp, herdr, PaneList, WorkspaceList } from "./lib/herdr";

function getFocusedCwd(): string {
  const ws = herdr<WorkspaceList>("workspace", "list").result.workspaces.find((w) => w.focused);
  if (!ws) throw new Error("No focused workspace");
  const pane = herdr<PaneList>("pane", "list").result.panes.find((p) => p.tab_id === ws.active_tab_id);
  if (!pane) throw new Error("No pane for active tab");
  return pane.foreground_cwd;
}

function fetchMain(cwd: string, branch: string): void {
  try {
    execFileSync("git", ["-C", cwd, "fetch", "origin", branch], { encoding: "utf8" });
  } catch { /* offline or no remote - proceed with local ref */ }
}

export default function NewWorktree() {
  const [cwd] = useState(() => {
    try { return getFocusedCwd(); } catch { return ""; }
  });

  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm
            title="Create Worktree"
            onSubmit={async ({ repo, branch, base }: { repo: string; branch: string; base: string }) => {
              const baseBranch = base.trim() || "main";
              fetchMain(repo, baseBranch);
              try {
                herdr("worktree", "create", "--cwd", repo, "--branch", branch, "--base", `origin/${baseBranch}`, "--focus");
                await closeMainWindow();
                focusTerminalApp();
              } catch (e) {
                await showToast({ style: Toast.Style.Failure, title: "Create failed", message: String(e) });
              }
            }}
          />
        </ActionPanel>
      }
    >
      <Form.TextField id="repo" title="Repo path" defaultValue={cwd} placeholder="/path/to/repo" />
      <Form.TextField id="branch" title="Branch" placeholder="feat/my-feature" />
      <Form.TextField id="base" title="Base branch" defaultValue="main" placeholder="main" />
    </Form>
  );
}
