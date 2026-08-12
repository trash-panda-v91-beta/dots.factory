import { closeMainWindow, showToast, Toast } from "@vicinae/api";
import { focusTerminalApp, getFocusedCwd, herdr, WorkspaceCreated } from "./lib/herdr";

export default async function OpenK9s() {
  try {
    const cwd = await getFocusedCwd();
    const tab = herdr<WorkspaceCreated>("tab", "create", "--cwd", cwd);
    herdr("tab", "rename", tab.result.tab.tab_id, "k9s");
    herdr("pane", "run", tab.result.root_pane.pane_id, "k9s");
    await closeMainWindow();
    focusTerminalApp();
  } catch (e) {
    await showToast({ style: Toast.Style.Failure, title: "Open k9s failed", message: String(e) });
  }
}
