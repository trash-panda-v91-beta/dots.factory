/**
 * Jetpack-styled pi TUI - flat single line, mirrors the nvim statusline.
 *
 * Header (line above content):
 *   ◎ pi v<ver>
 *
 * Working indicator (inline while streaming):
 *   ·∘◦○◎●◎○◦∘  (dot ramp - motion carried by shape, not color)
 *
 * Footer (line below content):
 *   repo △ branch          ⎪ ▴in ▿out ◈cost ⎥  provider∷model  ctx%
 *
 * Palette:
 *   ◎ / branch  = warning / accent (mirrors starship jetpack)
 *   ▴input      = success (green)  - flow up to model
 *   ▿output     = warning (yellow) - flow down from model
 *   ◈cost       = error   (red)    - outflow
 * Three-color chord = traffic light. Matches the nvim diff chord
 * (▴added ●changed ▿removed) so the two toolchains rhyme.
 */

import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI, Theme } from "@earendil-works/pi-coding-agent";
import { VERSION } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

const italic = (s: string) => `\x1b[3m${s}\x1b[23m`;

// Chrome margin - matches pi's `outputPad = 1` so header/footer align with messages.
const PAD = " ";

// Always show "k" so width doesn't jitter when a session crosses 1000.
// 0 -> "0"  ·  843 -> "0.8k"  ·  12345 -> "12k"  ·  123456 -> "123k"
const fmtTokens = (n: number) => {
	if (n === 0) return "0";
	if (n < 10_000) return `${(n / 1000).toFixed(1)}k`;
	return `${Math.round(n / 1000)}k`;
};

// Drop leading "0" for sub-dollar costs so the eye lands on the digits.
// 0 -> "0"  ·  0.014 -> ".014"  ·  1.234 -> "1.23"  ·  12.34 -> "12.3"
const fmtCost = (n: number) => {
	if (n === 0) return "0";
	if (n < 1) return `.${Math.round(n * 1000).toString().padStart(3, "0")}`;
	if (n < 100) return n.toFixed(2);
	return Math.round(n).toString();
};

const repoNameFromCwd = () => process.cwd().replace(/\/+$/, "").split("/").pop() ?? "";
const truncBranch = (b: string | null, max = 30) =>
	!b ? "" : b.length > max ? `${b.slice(0, max)}⋯` : b;

export default function (pi: ExtensionAPI) {
	let footerRepaint: (() => void) | null = null;

	pi.on("session_start", (_event, ctx) => {
		// Working indicator: dot ramp (·∘◦○◎●◎○◦∘). Motion in the shape, color stays flat.
		const frames = ["·", "∘", "◦", "○", "◎", "●", "◎", "○", "◦", "∘"];
		ctx.ui.setWorkingIndicator({
			frames: frames.map((f) => ctx.ui.theme.fg("muted", italic(f))),
			intervalMs: 100,
		});

		// Header: ◎ pi v<ver>   (◎ warning yellow, matches starship jetpack success char)
		ctx.ui.setHeader((_tui, theme: Theme) => ({
			render(width: number): string[] {
				const line = [
					theme.fg("warning", theme.bold("◎")),
					theme.fg("accent", theme.bold("pi")),
					theme.fg("dim", italic(`v${VERSION}`)),
				].join("  ");
				return [truncateToWidth(`${PAD}${line}`, width)];
			},
			invalidate() {},
		}));

		// Footer: repo △ branch          ⎪ ▴in ▿out ◈cost ⎥  provider∷model  ctx%
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
					const usage = ctx.getContextUsage();
					const ctxPct = usage?.percent != null ? `${Math.round(usage.percent)}%` : "";

					// Left: repo (accent bold)  △ branch (accent italic)
					const leftParts: string[] = [];
					if (repo) leftParts.push(theme.fg("accent", theme.bold(repo)));
					if (branch) {
						leftParts.push(
							`${theme.fg("accent", italic("△"))} ${theme.fg("accent", italic(branch))}`,
						);
					}
					const left = leftParts.join("  ");

					// Right cluster A: ⎪ ▴in ▿out ◈cost ⎥
					// Three-color traffic-light chord: green in, yellow out, red cost.
					// Hidden until the session accrues any cost, so fresh state stays clean.
					const hasStats = input > 0 || output > 0 || cost > 0;
					const stats = hasStats
						? [
								theme.fg("dim", italic("⎪")),
								theme.fg("success", italic(`▴${fmtTokens(input)}`)),
								theme.fg("warning", italic(`▿${fmtTokens(output)}`)),
								theme.fg("error", italic(`◈${fmtCost(cost)}`)),
								theme.fg("dim", italic("⎥")),
							].join(" ")
						: "";

					// Right cluster B: provider∷model  (provider dim, model accent, like nvim's `nix ✶`)
					const modelLabel = provider
						? `${theme.fg("dim", italic(`${provider}∷`))}${theme.fg("accent", italic(modelName))}`
						: theme.fg("accent", italic(modelName));

					// Right cluster C: ctx% (dim, bare — mirrors nvim's bare `42:8` location)
					const ctxLabel = ctxPct ? theme.fg("dim", italic(ctxPct)) : "";

					// Two-space breathing room between clusters (matches nvim right side).
					const rightClusters = [stats, modelLabel, ctxLabel].filter((s) => s.length > 0);
					const right = rightClusters.join("  ");

					const gap = Math.max(1, width - visibleWidth(left) - visibleWidth(right) - PAD.length * 2);
					return [truncateToWidth(`${PAD}${left}${" ".repeat(gap)}${right}${PAD}`, width)];
				},
			};
		});
	});

	pi.on("model_select", () => footerRepaint?.());
	pi.on("agent_end", () => footerRepaint?.());

	pi.on("session_shutdown", () => {
		footerRepaint = null;
	});
}
