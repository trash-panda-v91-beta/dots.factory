/**
 * Jetpack-styled pi TUI: header, footer, working indicator.
 *
 * Header:  ◎ pi v<ver>
 * Footer:  repo △ branch          ⎪▴in ▿out ◈cost⎥  provider∷model
 *
 * One anchor (◎) reserved for the header brand.
 * One accent hue for the "location" cluster (repo + branch + brackets).
 * Cost is the only loud colour (error) - money leaving the system.
 * Provider prefix flows as one dim label into the accent model name.
 */

import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI, Theme } from "@earendil-works/pi-coding-agent";
import { VERSION } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

const italic = (s: string) => `\x1b[3m${s}\x1b[23m`;

// Chrome margin. Matches pi's `outputPad = 1` so header/footer align with messages.
const PAD = " ";

// Always show "k" so the width doesn't jitter when a session crosses 1000.
// 0 -> "0"  ·  843 -> "0.8k"  ·  12345 -> "12k"  ·  123456 -> "123k"
const fmtTokens = (n: number) => {
	if (n === 0) return "0";
	if (n < 1000) return `${(n / 1000).toFixed(1)}k`;
	if (n < 10_000) return `${(n / 1000).toFixed(1)}k`;
	return `${Math.round(n / 1000)}k`;
};

// Drop the leading "0" for sub-dollar costs so the eye lands on the digits.
// 0 -> "0"  ·  0.014 -> ".014"  ·  1.234 -> "1.23"  ·  12.34 -> "12.3"
const fmtCost = (n: number) => {
	if (n === 0) return "0";
	if (n < 1) return `.${Math.round(n * 1000).toString().padStart(3, "0")}`;
	if (n < 100) return n.toFixed(2);
	return Math.round(n).toString();
};

const repoNameFromCwd = () => process.cwd().replace(/\/+$/, "").split("/").pop() ?? "";
const truncBranch = (b: string | null, max = 40) =>
	!b ? "" : b.length > max ? `${b.slice(0, max)}⋯` : b;

export default function (pi: ExtensionAPI) {
	let footerRepaint: (() => void) | null = null;

	pi.on("session_start", (_event, ctx) => {
		// Working indicator: shape ramp carries the motion, colour stays flat.
		const frames = ["·", "∘", "◦", "○", "◎", "●", "◎", "○", "◦", "∘"];
		ctx.ui.setWorkingIndicator({
			frames: frames.map((f) => ctx.ui.theme.fg("muted", italic(f))),
			intervalMs: 100,
		});

		// Header: ◎ pi v<ver>   (brand only - no keybinding hints, operator mode)
		ctx.ui.setHeader((_tui, theme: Theme) => ({
			render(width: number): string[] {
				const line = [
					theme.fg("success", theme.bold("◎")),
					theme.fg("accent", theme.bold("pi")),
					theme.fg("dim", italic(`v${VERSION}`)),
				].join("  ");
				return [truncateToWidth(`${PAD}${line}`, width)];
			},
			invalidate() {},
		}));

		// Footer: repo △ branch          ⎪▴in ▿out ◈cost⎥  provider∷model
		ctx.ui.setFooter((tui, theme: Theme, footerData) => {
			footerRepaint = () => tui.requestRender();
			const unsubBranch = footerData.onBranchChange(() => tui.requestRender());

			return {
				dispose() {
					unsubBranch();
					footerRepaint = null;
				},
				invalidate() {},
				render(width: number): string[] {
					let input = 0, output = 0, cost = 0;
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
					const provider = ctx.model?.provider ?? null;
					const modelName = ctx.model?.id ?? "no-model";

					// Left: repo (accent) △ branch (success) - two hues split location vs git state
					const leftParts: string[] = [];
					if (repo) leftParts.push(theme.fg("accent", theme.bold(repo)));
					if (branch) {
						leftParts.push(
							`${theme.fg("success", theme.bold(italic("△")))} ${theme.fg("success", italic(branch))}`,
						);
					}
					const left = leftParts.join(" ");

					// Right: ⎪ stats ⎥  provider∷model  (brackets dim, cost the only loud hue)
					const bracketL = theme.fg("dim", italic("⎪"));
					const bracketR = theme.fg("dim", italic("⎥"));
					const stats = [
						theme.fg("accent", italic(`▴${fmtTokens(input)}`)),
						theme.fg("accent", italic(`▿${fmtTokens(output)}`)),
						theme.fg("error", italic(`◈${fmtCost(cost)}`)),
					].join(" ");
					const modelLabel = provider
						? `${theme.fg("dim", italic(`${provider}∷`))}${theme.fg("accent", italic(modelName))}`
						: theme.fg("accent", italic(modelName));
					const right = `${bracketL}${stats}${bracketR}  ${modelLabel}`;

					const gap = Math.max(1, width - visibleWidth(left) - visibleWidth(right) - PAD.length * 2);
					return [truncateToWidth(`${PAD}${left}${" ".repeat(gap)}${right}${PAD}`, width)];
				},
			};
		});
	});

	pi.on("model_select", () => footerRepaint?.());

	pi.on("session_shutdown", () => {
		footerRepaint = null;
	});
}
