import { execFileSync } from "node:child_process";
import {
  Action,
  ActionPanel,
  closeMainWindow,
  getPreferenceValues,
  Icon,
  List,
  open,
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
  source: string;
}

function resolveMise(): string {
  return getPreferenceValues<Preferences>().misePath
    .replace(/^~/, process.env.HOME ?? "");
}

function loadTasks(): MiseTask[] {
  const raw = execFileSync(resolveMise(), ["tasks", "ls", "--json"], { encoding: "utf8" });
  return (JSON.parse(raw) as MiseTask[]).filter((t) => !t.name.startsWith("_"));
}

function sourceDir(task: MiseTask): string {
  return task.source.replace(/\/[^/]+$/, "");
}

export default function Tasks() {
  const [tasks, setTasks] = useState<MiseTask[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    try {
      setTasks(loadTasks());
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
          accessories={[{ text: sourceDir(task).replace(process.env.HOME ?? "", "~") }]}
          actions={
            <ActionPanel>
              <Action
                title="Run Task"
                icon={Icon.Play}
                onAction={async () => {
                  await closeMainWindow();
                  try {
                    execFileSync("herdr", [
                      "pane", "create",
                      "--cwd", sourceDir(task),
                      "--focus",
                      "--run", `${resolveMise()} run ${task.name}`,
                    ]);
                  } catch (e) {
                    await showToast({ style: Toast.Style.Failure, title: "Run failed", message: String(e) });
                  }
                }}
              />
              <Action
                title="Open in Finder"
                icon={Icon.Finder}
                onAction={() => open(sourceDir(task))}
              />
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}
