import { execFileSync } from "node:child_process";
import {
  Action,
  ActionPanel,
  closeMainWindow,
  getPreferenceValues,
  Icon,
  List,
  showToast,
  Toast,
} from "@vicinae/api";
import { useEffect, useState } from "react";

interface Preferences {
  misePath: string;
}

interface MiseTask {
  name: string;
  description: string;
}

function resolveMise(): string {
  return getPreferenceValues<Preferences>().misePath
    .replace(/^~/, process.env.HOME ?? "");
}

function herdr(...args: string[]): unknown {
  return JSON.parse(execFileSync("herdr", args, { encoding: "utf8" }));
}

function getFocusedCwd(): { wsId: string; cwd: string } {
  const workspaces = (herdr("workspace", "list") as { result: { workspaces: Array<{ workspace_id: string; active_tab_id: string; focused: boolean }> } }).result.workspaces;
  const ws = workspaces.find((w) => w.focused);
  if (!ws) throw new Error("No focused workspace");

  const panes = (herdr("pane", "list") as { result: { panes: Array<{ tab_id: string; foreground_cwd: string }> } }).result.panes;
  const pane = panes.find((p) => p.tab_id === ws.active_tab_id);
  if (!pane) throw new Error("No pane for active tab");

  return { wsId: ws.workspace_id, cwd: pane.foreground_cwd };
}

function loadTasks(cwd: string): MiseTask[] {
  const raw = execFileSync(resolveMise(), ["tasks", "ls", "--json"], {
    encoding: "utf8",
    cwd,
  });
  return (JSON.parse(raw) as MiseTask[]).filter((t) => !t.name.startsWith("_"));
}

function runTask(wsId: string, cwd: string, taskName: string): void {
  const created = herdr("tab", "create", "--workspace", wsId, "--label", taskName) as {
    result: { tab: { tab_id: string }; root_pane: { pane_id: string } };
  };
  const { tab_id, } = created.result.tab;
  const { pane_id } = created.result.root_pane;
  execFileSync("herdr", ["pane", "run", pane_id, `${resolveMise()} run ${taskName}`]);
  execFileSync("herdr", ["tab", "focus", tab_id]);
}

export default function Tasks() {
  const [tasks, setTasks] = useState<MiseTask[]>([]);
  const [ctx, setCtx] = useState<{ wsId: string; cwd: string } | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    try {
      const focused = getFocusedCwd();
      setCtx(focused);
      setTasks(loadTasks(focused.cwd));
    } catch (e) {
      showToast({ style: Toast.Style.Failure, title: "Load failed", message: String(e) });
    } finally {
      setLoading(false);
    }
  }, []);

  return (
    <List isLoading={loading} searchBarPlaceholder="Run mise task...">
      {tasks.map((task) => (
        <List.Item
          key={task.name}
          title={task.name}
          subtitle={task.description}
          icon={Icon.Bolt}
          actions={
            <ActionPanel>
              <Action
                title="Run Task"
                icon={Icon.Play}
                onAction={async () => {
                  if (!ctx) return;
                  await closeMainWindow();
                  try {
                    runTask(ctx.wsId, ctx.cwd, task.name);
                  } catch (e) {
                    await showToast({ style: Toast.Style.Failure, title: "Run failed", message: String(e) });
                  }
                }}
              />
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}
