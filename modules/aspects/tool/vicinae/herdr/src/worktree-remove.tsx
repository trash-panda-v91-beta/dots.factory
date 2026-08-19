import { closeMainWindow, showToast, Toast } from "@vicinae/api";
import { herdrAsync, WorkspaceList, WorktreeList } from "./lib/herdr";

export default async function WorktreeRemove() {
  const toast = await showToast({ style: Toast.Style.Animated, title: "Removing worktree" });
  try {
    const wsList = await herdrAsync<WorkspaceList>("workspace", "list");
    const ws = wsList.result.workspaces.find((w) => w.focused);
    if (!ws) throw new Error("No focused workspace");

    const wtList = await herdrAsync<WorktreeList>("worktree", "list", "--workspace", ws.workspace_id);
    const wt = wtList.result.worktrees.find((w) => w.open_workspace_id === ws.workspace_id);
    if (!wt) throw new Error("Focused workspace is not a worktree");
    if (!wt.is_linked_worktree) throw new Error("Cannot remove main worktree");

    await herdrAsync("worktree", "remove", "--workspace", ws.workspace_id);
    toast.style = Toast.Style.Success;
    toast.title = "Worktree removed";
    toast.message = wt.branch;
    await closeMainWindow();
  } catch (e) {
    toast.style = Toast.Style.Failure;
    toast.title = "Remove failed";
    toast.message = String(e);
  }
}
