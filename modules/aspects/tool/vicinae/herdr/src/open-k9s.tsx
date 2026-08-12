import { closeMainWindow, showToast, Toast } from "@vicinae/api";
import { focusTerminalApp, herdr, herdrAsync, PaneList, TabList, WorkspaceCreated, WorkspaceList } from "./lib/herdr";

async function getFocusedContext(): Promise<{ wsId: string; cwd: string }> {
  const [wsList, paneList] = await Promise.all([
    herdrAsync<WorkspaceList>("workspace", "list"),
    herdrAsync<PaneList>("pane", "list"),
  ]);
  const ws = wsList.result.workspaces.find((w) => w.focused);
  if (!ws) throw new Error("No focused workspace");
  const pane = paneList.result.panes.find((p) => p.tab_id === ws.active_tab_id);
  if (!pane) throw new Error("No pane for active tab");
  return { wsId: ws.workspace_id, cwd: pane.foreground_cwd };
}

export default async function OpenK9s() {
  try {
    const [{ wsId, cwd }, tabList] = await Promise.all([
      getFocusedContext(),
      herdrAsync<TabList>("tab", "list"),
    ]);

    const existing = tabList.result.tabs.find((t) => t.workspace_id === wsId && t.label === "k9s");
    if (existing) {
      herdr("tab", "focus", existing.tab_id);
    } else {
      const tab = herdr<WorkspaceCreated>("tab", "create", "--cwd", cwd, "--focus");
      herdr("tab", "rename", tab.result.tab.tab_id, "k9s");
      herdr("pane", "run", tab.result.root_pane.pane_id, "k9s");
    }

    await closeMainWindow();
    focusTerminalApp();
  } catch (e) {
    await showToast({ style: Toast.Style.Failure, title: "Open k9s failed", message: String(e) });
  }
}
