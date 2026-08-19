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
 *   repo △ branch          ⎪ ▴in ▿out ◈cost ⎥  ⬡N  ◈level  provider∷model  ctx%
 *
 * Palette:
 *   ◎ / branch  = warning / accent (mirrors starship jetpack)
 *   ▴input      = success (green)  - flow up to model
 *   ▿output     = warning (yellow) - flow down from model
 *   ◈cost       = error   (red)    - outflow
 *   ⬡N (mcps)  = borderAccent     - connected MCP servers (hexagon = geometry motif)
 *   thinking    = thinkingOff..thinkingMax tokens - current reasoning level
 * Three-color chord = traffic light. Matches the nvim diff chord
 * (▴added ●changed ▿removed) so the two toolchains rhyme.
 */

import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI, Theme } from "@earendil-works/pi-coding-agent";
import { VERSION } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

type ThinkingLevel = "off" | "minimal" | "low" | "medium" | "high" | "xhigh" | "max";
type ThinkingColorToken =
	| "thinkingOff"
	| "thinkingMinimal"
	| "thinkingLow"
	| "thinkingMedium"
	| "thinkingHigh"
	| "thinkingXhigh"
	| "thinkingMax";

// Maps thinking level -> theme color token
const THINKING_TOKEN: Record<ThinkingLevel, ThinkingColorToken> = {
	off: "thinkingOff",
	minimal: "thinkingMinimal",
	low: "thinkingLow",
	medium: "thinkingMedium",
	high: "thinkingHigh",
	xhigh: "thinkingXhigh",
	max: "thinkingMax",
};

// Geometry-style glyphs: concentric circles = thinking depth
const THINKING_GLYPH: Record<ThinkingLevel, string> = {
	off: "·",     // dim dot - inactive
	minimal: "○", // open circle
	low: "◌",     // dashed circle
	medium: "◎",  // bullseye (matches header glyph)
	high: "●",    // filled circle
	xhigh: "◉",   // fisheye - full + ring
	max: "⦿",     // circle with dot - maximum
};

const MCP_STATUS_EVENT = "pi-mcp-adapter/status/v1";

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
	let mcpConnected = 0;

	// Track MCP server count via pi-mcp-adapter events
	pi.events.on(MCP_STATUS_EVENT, (data: { connectedCount?: number }) => {
		mcpConnected = data?.connectedCount ?? 0;
		footerRepaint?.();
	});

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

		// Footer: repo △ branch          ⎪ ▴in ▿out ◈cost ⎥  ⬡N  glyph+level  provider∷model  ctx%
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
					const level = (ctx.thinkingLevel ?? "off") as ThinkingLevel;

					// Left: repo (accent bold)  △ branch (borderAccent italic)
					const leftParts: string[] = [];
					if (repo) leftParts.push(theme.fg("accent", theme.bold(repo)));
					if (branch) {
						leftParts.push(
							`${theme.fg("borderAccent", italic("△"))} ${theme.fg("borderAccent", italic(branch))}`,
						);
					}
					const left = leftParts.join("  ");

					// Right cluster A: ⎪ ▴in ▿out ◈cost ⎥
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

					// Right cluster B: ⬡N - connected MCP count (hexagon = geometry motif)
					// Shown only when at least one server is connected.
					const mcpLabel = mcpConnected > 0
						? theme.fg("borderAccent", italic(`⬡ ${mcpConnected}`))
						: "";

					// Right cluster C: thinking level - geometry glyph + level name, colored by level
					// glyph only when off; glyph+name otherwise so the eye reads both shape and depth
					const thinkingText = level === "off"
						? THINKING_GLYPH[level]
						: `${THINKING_GLYPH[level]} ${level}`;
					const thinkingLabel = theme.fg(THINKING_TOKEN[level], italic(thinkingText));

					// Right cluster D: provider∷model
					const modelLabel = provider
						? `${theme.fg("dim", italic(`${provider}∷`))}${theme.fg("accent", italic(modelName))}`
						: theme.fg("accent", italic(modelName));

					// Right cluster E: ctx%
					const ctxLabel = ctxPct ? theme.fg("dim", italic(ctxPct)) : "";

					const rightClusters = [stats, mcpLabel, thinkingLabel, modelLabel, ctxLabel].filter(
						(s) => s.length > 0,
					);
					const right = rightClusters.join("   ");

					const gap = Math.max(1, width - visibleWidth(left) - visibleWidth(right) - PAD.length * 2);
					return [truncateToWidth(`${PAD}${left}${" ".repeat(gap)}${right}${PAD}`, width)];
				},
			};
		});
	});

	pi.on("model_select", () => footerRepaint?.());
	pi.on("thinking_level_select", () => footerRepaint?.());
	pi.on("agent_end", () => footerRepaint?.());

	pi.on("session_shutdown", () => {
		footerRepaint = null;
	});
}
