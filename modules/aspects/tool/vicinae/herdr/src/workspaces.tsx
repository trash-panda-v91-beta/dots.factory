import { existsSync } from "node:fs";
import {
  Action,
  ActionPanel,
  Cache,
  closeMainWindow,
  Color,
  Icon,
  List,
  showToast,
  Toast,
} from "@vicinae/api";
import { useCallback, useEffect, useState } from "react";
import {
  AgentStatus,
  execAsync,
  focusTerminalApp,
  herdr,
  herdrAsync,
  PaneList,
  resolveZoxide,
  WorkspaceCreated,
  WorkspaceList,
  WorktreeList,
} from "./lib/herdr";

type Filter = AgentStatus | "all";

interface Workspace {
  wsId: string;
  label: string;
  agentStatus: AgentStatus;
  focused: boolean;
}

interface DirEntry {
  dir: string;
  workspace: Workspace | undefined;
  branch?: string;
}

function openNewWorkspace(dir: string): void {
  const created = herdr<WorkspaceCreated>("workspace", "create", "--cwd", dir, "--focus");
  herdr("tab", "rename", created.result.tab.tab_id, "git");
  herdr("pane", "run", created.result.root_pane.pane_id, "nvim -c Neogit");
}

function getWorktrees(dir: string): Array<{ dir: string; branch: string }> {
  try {
    return herdr<WorktreeList>("worktree", "list", "--cwd", dir)
      .result.worktrees.map((wt) => ({ dir: wt.path, branch: wt.branch }));
  } catch {
    return [];
  }
}

const STATUS_COLOR: Record<AgentStatus, Color> = {
  working: Color.Yellow,
  blocked: Color.Red,
  idle:    Color.Green,
  done:    Color.Blue,
  unknown: Color.SecondaryText,
};

const STATUS_ICON: Record<AgentStatus, Icon> = {
  working: Icon.CircleProgress,
  blocked: Icon.ExclamationMark,
  idle:    Icon.CheckCircle,
  done:    Icon.CheckCircle,
  unknown: Icon.QuestionMark,
};

const FILTERS: { value: Filter; label: string }[] = [
  { value: "all",     label: "All"     },
  { value: "working", label: "Working" },
  { value: "blocked", label: "Blocked" },
  { value: "idle",    label: "Idle"    },
  { value: "done",    label: "Done"    },
];

async function loadEntries(): Promise<DirEntry[]> {
  const [wsResult, paneResult, zoxRaw] = await Promise.all([
    herdrAsync<WorkspaceList>("workspace", "list"),
    herdrAsync<PaneList>("pane", "list"),
    execAsync(resolveZoxide(), ["query", "-l"]),
  ]);

  const wsList: Workspace[] = wsResult.result.workspaces.map((w) => ({
    wsId: w.workspace_id,
    label: w.label,
    agentStatus: w.agent_status,
    focused: w.focused,
  }));

  const cwdByWsId = new Map<string, string>();
  for (const p of paneResult.result.panes) {
    if (!cwdByWsId.has(p.workspace_id)) cwdByWsId.set(p.workspace_id, p.cwd);
  }

  const workspaceByCwd = new Map<string, Workspace>();
  for (const ws of wsList) {
    const cwd = cwdByWsId.get(ws.wsId);
    if (cwd) workspaceByCwd.set(cwd, ws);
  }

  const zoxDirs = zoxRaw.trim().split("\n").filter(Boolean);
  const openOnlyDirs = [...workspaceByCwd.keys()].filter((d) => !zoxDirs.includes(d));

  return [...openOnlyDirs, ...zoxDirs].map((dir) => ({
    dir,
    workspace: workspaceByCwd.get(dir),
  }));
}

function enrichWithWorktrees(entries: DirEntry[]): DirEntry[] {
  const allDirSet = new Set(entries.map((e) => e.dir));
  const branchByDir = new Map<string, string>();
  const extraDirs: string[] = [];
  const seenMainWorktree = new Set<string>();

  for (const { dir } of entries) {
    if (!existsSync(dir + "/.git")) continue;
    const worktrees = getWorktrees(dir);
    if (worktrees.length === 0) continue;
    const mainDir = worktrees[0].dir;
    if (seenMainWorktree.has(mainDir)) continue;
    seenMainWorktree.add(mainDir);
    for (const wt of worktrees) {
      branchByDir.set(wt.dir, wt.branch);
      if (!allDirSet.has(wt.dir)) { extraDirs.push(wt.dir); allDirSet.add(wt.dir); }
    }
  }

  if (branchByDir.size === 0 && extraDirs.length === 0) return entries;

  const enriched = entries.map((e) =>
    branchByDir.has(e.dir) ? { ...e, branch: branchByDir.get(e.dir) } : e
  );
  return [...enriched, ...extraDirs.map((dir) => ({ dir, workspace: undefined, branch: branchByDir.get(dir) }))];
}

function applyFilter(entries: DirEntry[], filter: Filter): DirEntry[] {
  if (filter === "all") return entries;
  return entries.filter((e) => e.workspace?.agentStatus === filter);
}

const cache = new Cache();
const CACHE_KEY = "entries.v1";

function readCache(): DirEntry[] {
  const raw = cache.get(CACHE_KEY);
  if (!raw) return [];
  try { return JSON.parse(raw) as DirEntry[]; } catch { return []; }
}

function writeCache(entries: DirEntry[]): void {
  try { cache.set(CACHE_KEY, JSON.stringify(entries)); } catch { /* ignore */ }
}

export default function Workspaces() {
  const [entries, setEntries] = useState<DirEntry[]>(readCache);
  const [filter, setFilter] = useState<Filter>("all");
  const [loading, setLoading] = useState(entries.length === 0);

  const reload = useCallback(async () => {
    let base: DirEntry[];
    try {
      base = await loadEntries();
    } catch (e) {
      showToast({ style: Toast.Style.Failure, title: "Load failed", message: String(e) });
      setLoading(false);
      return;
    }
    setEntries(base);
    setLoading(false);
    writeCache(base);
    setTimeout(() => {
      try {
        const enriched = enrichWithWorktrees(base);
        setEntries(enriched);
        writeCache(enriched);
      } catch { /* ignore */ }
    }, 0);
  }, []);

  useEffect(() => { void reload(); }, [reload]);

  const toggleFilter = useCallback((value: AgentStatus) => {
    setFilter((cur) => cur === value ? "all" : value);
  }, []);

  const visible = applyFilter(entries, filter);

  return (
    <List
      isLoading={loading}
      searchBarPlaceholder="Jump to directory..."
      searchBarAccessory={
        <List.Dropdown tooltip="Filter by agent status" value={filter} onChange={(v) => setFilter(v as Filter)}>
          {FILTERS.map(({ value, label }) => (
            <List.Dropdown.Item key={value} title={label} value={value} />
          ))}
        </List.Dropdown>
      }
    >
      {visible.map(({ dir, workspace, branch }) => {
        const label = dir.replace(process.env.HOME ?? "", "~");
        const status = workspace?.agentStatus;

        return (
          <List.Item
            key={dir}
            title={label}
            subtitle={branch}
            icon={
              workspace
                ? { source: STATUS_ICON[workspace.agentStatus], tintColor: STATUS_COLOR[workspace.agentStatus] }
                : Icon.Folder
            }
            accessories={[
              ...(status && status !== "unknown"
                ? [{ tag: { value: status, color: STATUS_COLOR[status] } }]
                : []),
              ...(workspace?.focused ? [{ tag: { value: "focused", color: Color.Blue } }] : []),
            ]}
            actions={
              <ActionPanel>
                {workspace ? (
                  <>
                    <Action
                      title="Switch to Workspace"
                      icon={Icon.Terminal}
                      onAction={async () => {
                        await closeMainWindow();
                        try {
                          herdr("workspace", "focus", workspace.wsId);
                          focusTerminalApp();
                        }
                        catch (e) { await showToast({ style: Toast.Style.Failure, title: "Focus failed", message: String(e) }); }
                      }}
                    />
                    <Action
                      title="Close Workspace"
                      icon={Icon.Trash}
                      style={Action.Style.Destructive}
                      shortcut={{ modifiers: ["cmd"], key: "delete" }}
                      onAction={async () => {
                        try {
                          herdr("workspace", "close", workspace.wsId);
                          reload();
                        } catch (e) {
                          await showToast({ style: Toast.Style.Failure, title: "Close failed", message: String(e) });
                        }
                      }}
                    />
                  </>
                ) : (
                  <Action
                    title="Open Workspace"
                    icon={Icon.Plus}
                    onAction={async () => {
                      await closeMainWindow();
                      try { openNewWorkspace(dir); focusTerminalApp(); }
                      catch (e) { await showToast({ style: Toast.Style.Failure, title: "Open failed", message: String(e) }); }
                    }}
                  />
                )}

                <ActionPanel.Section title="Filter">
                  <Action title="Show All" icon={Icon.List}           shortcut={{ modifiers: ["opt"], key: "a" }} onAction={() => setFilter("all")} />
                  <Action title="Working"  icon={Icon.CircleProgress}  shortcut={{ modifiers: ["opt"], key: "w" }} onAction={() => toggleFilter("working")} />
                  <Action title="Blocked"  icon={Icon.ExclamationMark} shortcut={{ modifiers: ["opt"], key: "b" }} onAction={() => toggleFilter("blocked")} />
                  <Action title="Idle"     icon={Icon.CheckCircle}     shortcut={{ modifiers: ["opt"], key: "i" }} onAction={() => toggleFilter("idle")} />
                  <Action title="Done"     icon={Icon.CheckCircle}     shortcut={{ modifiers: ["opt"], key: "e" }} onAction={() => toggleFilter("done")} />
                </ActionPanel.Section>

                <ActionPanel.Section>
                  <Action title="Refresh" icon={Icon.ArrowClockwise} shortcut={{ modifiers: ["cmd"], key: "r" }} onAction={reload} />
                </ActionPanel.Section>
              </ActionPanel>
            }
          />
        );
      })}
    </List>
  );
}
