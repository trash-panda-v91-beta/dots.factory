import { execFileSync } from "node:child_process";
import {
  Action,
  ActionPanel,
  closeMainWindow,
  Color,
  getPreferenceValues,
  Icon,
  List,
  showToast,
  Toast,
} from "@vicinae/api";
import { useCallback, useEffect, useState } from "react";

interface Preferences {
  zoxidePath: string;
  herdrPath: string;
  herdrAppName: string;
}

function resolveZoxide(): string {
  return getPreferenceValues<Preferences>().zoxidePath
    .replace(/^~/, process.env.HOME ?? "");
}

function resolveAppName(): string {
  return getPreferenceValues<Preferences>().herdrAppName || "Ghostty";
}

function resolveHerdr(): string {
  return getPreferenceValues<Preferences>().herdrPath
    .replace(/^~/, process.env.HOME ?? "");
}

function herdr(...args: string[]): string {
  return execFileSync(resolveHerdr(), args, { encoding: "utf8" });
}

function applyLayout(wsId: string, tab1Id: string, tab1Pane: string): void {
  herdr("tab", "rename", tab1Id, "nvim");
  herdr("pane", "run", tab1Pane, "nvim");

  const tab2 = JSON.parse(herdr("tab", "create", "--workspace", wsId, "--label", "ai", "--no-focus"));
  herdr("pane", "run", tab2.result.root_pane.pane_id, "pi --resume");

  herdr("tab", "create", "--workspace", wsId, "--label", "git", "--no-focus");
  herdr("tab", "create", "--workspace", wsId, "--label", "pr", "--no-focus");
  herdr("tab", "create", "--workspace", wsId, "--label", "term", "--no-focus");
}

function openNewWorkspace(dir: string): void {
  const created = JSON.parse(herdr("workspace", "create", "--cwd", dir, "--focus"));
  const r = created.result;
  applyLayout(
    r.workspace?.workspace_id ?? r.workspace_id,
    r.tab?.tab_id ?? r.tab_id,
    r.root_pane?.pane_id ?? r.pane_id,
  );
}

type AgentStatus = "working" | "blocked" | "idle" | "done" | "unknown";
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

function loadEntries(): DirEntry[] {
  const wsList: Workspace[] = JSON.parse(herdr("workspace", "list"))
    .result.workspaces.map((w: {
      workspace_id: string;
      label: string;
      agent_status: AgentStatus;
      focused: boolean;
    }) => ({
      wsId: w.workspace_id,
      label: w.label,
      agentStatus: w.agent_status,
      focused: w.focused,
    }));

  const cwdByWsId = new Map<string, string>();
  for (const p of JSON.parse(herdr("pane", "list")).result.panes as Array<{
    workspace_id: string;
    cwd: string;
  }>) {
    if (!cwdByWsId.has(p.workspace_id)) cwdByWsId.set(p.workspace_id, p.cwd);
  }

  const workspaceByCwd = new Map<string, Workspace>();
  for (const ws of wsList) {
    const cwd = cwdByWsId.get(ws.wsId);
    if (cwd) workspaceByCwd.set(cwd, ws);
  }

  const zoxDirs = execFileSync(resolveZoxide(), ["query", "-l"], {
    encoding: "utf8",
  })
    .trim()
    .split("\n")
    .filter(Boolean);

  const openOnlyDirs = [...workspaceByCwd.keys()].filter((d) => !zoxDirs.includes(d));

  return [...openOnlyDirs, ...zoxDirs].map((dir) => ({
    dir,
    workspace: workspaceByCwd.get(dir),
  }));
}

function applyFilter(entries: DirEntry[], filter: Filter): DirEntry[] {
  if (filter === "all") return entries;
  return entries.filter((e) => e.workspace?.agentStatus === filter);
}

export default function Jump() {
  const [entries, setEntries] = useState<DirEntry[]>([]);
  const [filter, setFilter] = useState<Filter>("all");
  const [loading, setLoading] = useState(true);

  const reload = useCallback(() => {
    setLoading(true);
    try {
      setEntries(loadEntries());
    } catch (e) {
      showToast({ style: Toast.Style.Failure, title: "Load failed", message: String(e) });
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { reload(); }, [reload]);

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
      {visible.map(({ dir, workspace }) => {
        const label = dir.replace(process.env.HOME ?? "", "~");
        const status = workspace?.agentStatus;

        return (
          <List.Item
            key={dir}
            title={label}
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
                          execFileSync("/usr/bin/open", ["-a", resolveAppName()]);
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
                      try { openNewWorkspace(dir); }
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
