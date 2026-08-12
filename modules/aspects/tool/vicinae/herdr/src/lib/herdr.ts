import { execFile, execFileSync } from "node:child_process";
import { promisify } from "node:util";
import { getPreferenceValues } from "@vicinae/api";

export interface Preferences {
  herdrPath: string;
  zoxidePath: string;
  herdrAppName: string;
}

export type AgentStatus = "working" | "blocked" | "idle" | "done" | "unknown";

export interface WorkspaceInfo {
  workspace_id: string;
  label: string;
  agent_status: AgentStatus;
  focused: boolean;
  active_tab_id: string;
}

export interface PaneInfo {
  pane_id: string;
  workspace_id: string;
  tab_id: string;
  cwd: string;
  foreground_cwd: string;
}

export interface WorktreeInfo {
  path: string;
  branch: string;
  is_linked_worktree: boolean;
}

export interface WorkspaceCreated {
  result: {
    root_pane: { pane_id: string };
    tab: { tab_id: string };
    workspace: { workspace_id: string; label: string };
  };
}

export interface TabInfo {
  tab_id: string;
  workspace_id: string;
  label: string;
  focused: boolean;
}

export interface WorkspaceList  { result: { workspaces: WorkspaceInfo[] } }
export interface PaneList       { result: { panes: PaneInfo[] } }
export interface WorktreeList   { result: { worktrees: WorktreeInfo[] } }
export interface TabList        { result: { tabs: TabInfo[] } }

function expandTilde(p: string): string {
  return p.replace(/^~/, process.env.HOME ?? "");
}

export const resolveHerdr   = () => expandTilde(getPreferenceValues<Preferences>().herdrPath);
export const resolveZoxide  = () => expandTilde(getPreferenceValues<Preferences>().zoxidePath);
export const resolveAppName = () => getPreferenceValues<Preferences>().herdrAppName || "Ghostty";

export function herdr<T = unknown>(...args: string[]): T {
  return JSON.parse(execFileSync(resolveHerdr(), args, { encoding: "utf8" })) as T;
}

const execFileP = promisify(execFile);

export async function herdrAsync<T = unknown>(...args: string[]): Promise<T> {
  const { stdout } = await execFileP(resolveHerdr(), args, { encoding: "utf8" });
  return JSON.parse(stdout as string) as T;
}

export async function execAsync(cmd: string, args: string[]): Promise<string> {
  const { stdout } = await execFileP(cmd, args, { encoding: "utf8" });
  return stdout as string;
}

export async function getFocusedCwd(): Promise<string> {
  const wsList = await herdrAsync<WorkspaceList>("workspace", "list");
  const ws = wsList.result.workspaces.find((w) => w.focused);
  if (!ws) throw new Error("No focused workspace");
  const paneList = await herdrAsync<PaneList>("pane", "list");
  const pane = paneList.result.panes.find((p) => p.tab_id === ws.active_tab_id);
  if (!pane) throw new Error("No pane for active tab");
  return pane.foreground_cwd;
}

// open -a only raises the app within macOS; aerospace keeps showing the old
// workspace. Focus the app's window through aerospace so its workspace comes
// forward too. Falls back to open -a when aerospace or the window is absent.
export function focusTerminalApp(): void {
  const appName = resolveAppName();
  try {
    const line = execFileSync(
      "aerospace",
      ["list-windows", "--all", "--format", "%{window-id}|%{app-name}"],
      { encoding: "utf8" },
    )
      .split("\n")
      .find((l) => l.split("|")[1]?.trim() === appName);
    const windowId = line?.split("|")[0]?.trim();
    if (windowId) {
      execFileSync("aerospace", ["focus", "--window-id", windowId]);
      return;
    }
  } catch {
    // aerospace missing or errored - fall through to open -a
  }
  execFileSync("/usr/bin/open", ["-a", appName]);
}
