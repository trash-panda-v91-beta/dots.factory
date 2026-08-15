/**
 * Jetpack-styled pi footer.
 *
 * Mirrors starship jetpack's grammar on a single line:
 *   ◎ <repo_root> △ <branch>        ⎪↑in ↓out $cost⎥  <model>  HH:MM
 *
 * ◎ .............. jetpack character.success_symbol (bright-yellow bold)
 * <repo_root> ..... jetpack directory.repo_root_style (bold accent)
 * △ <branch> ...... jetpack git_branch.symbol + style (italic accent)
 * ⎪ ... ⎥ ......... jetpack git_status bracket (bold italic accent),
 *                    here wrapping session stats instead of git status details
 * time ............ jetpack time.style (italic dimmed white)
 *
 * Colors go through pi theme tokens so it respects the active theme.
 * Italic is emitted directly (SGR 3 / 23) - pi theme has no italic helper.
 */

import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

const italic = (s: string) => `\x1b[3m${s}\x1b[23m`;

const fmtCount = (n: number) => (n < 1000 ? `${n}` : `${(n / 1000).toFixed(1)}k`);

const hhmm = () => {
	const d = new Date();
	return `${String(d.getHours()).padStart(2, "0")}:${String(d.getMinutes()).padStart(2, "0")}`;
};

const repoNameFromCwd = () => {
	const cwd = process.cwd().replace(/\/+$/, "");
	return cwd.split("/").pop() ?? "";
};

const truncBranch = (b: string | null, max = 40) => {
	if (!b) return "";
	return b.length > max ? `${b.slice(0, max)}⋯` : b;
};

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		// Working indicator: jetpack pulse (density ramp).
		const frames = ["·", "∘", "◦", "○", "◎", "●", "◎", "○", "◦", "∘"];
		ctx.ui.setWorkingIndicator({
			frames: frames.map((f, i) => {
				const mid = frames.length / 2;
				const token = Math.abs(i - mid) < 2 ? "accent" : Math.abs(i - mid) < 4 ? "muted" : "dim";
				return ctx.ui.theme.fg(token, f);
			}),
			intervalMs: 100,
		});

		ctx.ui.setFooter((tui, theme, footerData) => {
			const unsubBranch = footerData.onBranchChange(() => tui.requestRender());
			// Live clock: repaint every 30s so time doesn't stale when idle.
			const tick = setInterval(() => tui.requestRender(), 30_000);

			return {
				dispose: () => {
					unsubBranch();
					clearInterval(tick);
				},
				invalidate() {},
				render(width: number): string[] {
					// Session stats (available to any extension)
					let input = 0;
					let output = 0;
					let cost = 0;
					for (const e of ctx.sessionManager.getBranch()) {
						if (e.type === "message" && e.message.role === "assistant") {
							const m = e.message as AssistantMessage;
							input += m.usage.input;
							output += m.usage.output;
							cost += m.usage.cost.total;
						}
					}

					const repo = repoNameFromCwd();
					const branch = truncBranch(footerData.getGitBranch());
					const model = ctx.model?.id ?? "no-model";
					const time = hhmm();

					// --- Left: ◎  repo  △ branch
					const leftParts: string[] = [
						theme.fg("success", theme.bold("◎")),
					];
					if (repo) leftParts.push(theme.fg("accent", theme.bold(repo)));
					if (branch) leftParts.push(theme.fg("accent", italic(`△ ${branch}`)));
					const left = leftParts.join(" ");

					// --- Right: ⎪↑in ↓out $cost⎥  model  HH:MM
					const bracketL = theme.fg("accent", theme.bold(italic("⎪")));
					const bracketR = theme.fg("accent", theme.bold(italic("⎥")));
					const stats = theme.fg(
						"muted",
						italic(`↑${fmtCount(input)} ↓${fmtCount(output)} $${cost.toFixed(3)}`),
					);
					const statsBlock = `${bracketL}${stats}${bracketR}`;
					const modelStr = theme.fg("muted", italic(model));
					const timeStr = theme.fg("dim", italic(time));
					const right = `${statsBlock}  ${modelStr}  ${timeStr}`;

					const gap = Math.max(1, width - visibleWidth(left) - visibleWidth(right));
					return [truncateToWidth(left + " ".repeat(gap) + right, width)];
				},
			};
		});
	});
}
