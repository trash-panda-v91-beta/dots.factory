import { closeMainWindow, showToast, Toast } from "@vicinae/api";
import { execAsync, getFocusedCwd } from "./lib/herdr";

async function git(cwd: string, ...args: string[]): Promise<void> {
  await execAsync("git", ["-C", cwd, ...args]);
}

export default async function SyncMain() {
  const toast = await showToast({ style: Toast.Style.Animated, title: "Syncing main" });
  try {
    const cwd = await getFocusedCwd();
    toast.title = "git switch main";
    await git(cwd, "switch", "main");
    toast.title = "git fetch";
    await git(cwd, "fetch");
    toast.title = "git pull";
    await git(cwd, "pull", "--ff-only");
    toast.style = Toast.Style.Success;
    toast.title = "main synced";
    toast.message = cwd;
    await closeMainWindow();
  } catch (e) {
    toast.style = Toast.Style.Failure;
    toast.title = "Sync failed";
    toast.message = String(e);
  }
}
