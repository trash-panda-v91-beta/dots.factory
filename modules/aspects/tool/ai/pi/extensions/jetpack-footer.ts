/**
 * Jetpack-styled pi TUI: header, bordered editor, footer.
 *
 * Header  (one line above content):
 *   ◎ pi v<ver>
 *
 * Editor chrome (top/bottom border around the input box):
 *   top:    ─── ◎ pi ──── (spinner while working) ──────────────────────────
 *   bottom: ─ ⌂ cwd  △ branch ───────────────────── provider∷model  ctx% ─
 *
 * Footer (one line below content):
 *   repo △ branch          ⎪ ▴in ▿out ◈cost ⎥  provider∷model
 *
 * Palette mirrors starship jetpack + cyberdream:
 *   success/◎ = warning (yellow)   branch = accent (blue)
 *   cost      = error   (red)      muted  = dim labels
 */

import type { AssistantMessage } from "@earendil-works/pi-ai";
import type {
	CustomEditor as CustomEditorType,
	ExtensionAPI,
	ExtensionContext,
	KeybindingsManager,
} from "@earendil-works/pi-coding-agent";
import { CustomEditor, VERSION } from "@earendil-works/pi-coding-agent";
import type { EditorTheme, TUI } from "@earendil-works/pi-tui";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

// ─── helpers ────────────────────────────────────────────────────────────────

const italic = (s: string) => `\x1b[3m${s}\x1b[23m`;
const PAD = " ";

// Token count -> "1.2k" / "12k" / "123k" (always show k so width is stable)
const fmtTokens = (n: number): string => {
	if (n === 0) return "0";
	if (n < 10_000) return `${(n / 1000).toFixed(1)}k`;
	return `${Math.round(n / 1000)}k`;
};

// Cost -> ".014" / "1.23" (no leading zero below $1 so eye lands on digits)
const fmtCost = (n: number): string => {
	if (n === 0) return "0";
	if (n < 1) return `.${Math.round(n * 1000).toString().padStart(3, "0")}`;
	if (n < 100) return n.toFixed(2);
	return Math.round(n).toString();
};

const repoName = () => process.cwd().replace(/\/+$/, "").split("/").pop() ?? "";
const truncBranch = (b: string | null, max = 30) =>
	!b ? "" : b.length > max ? `${b.slice(0, max)}⋯` : b;

// fitBorder: fills a horizontal rule with optional left/right labels.
// Adapted from border-status-editor example (pi repo).
function fitBorder(
	left: string,
	right: string,
	width: number,
	fill: (s: string) => string,
): string {
	if (width <= 0) return "";
	const MIN_GAP = 3;
	let l = left;
	let r = right;
	while (2 + visibleWidth(l) + visibleWidth(r) + MIN_GAP > width && visibleWidth(r) > 0)
		r = truncateToWidth(r, Math.max(0, visibleWidth(r) - 1), "");
	while (2 + visibleWidth(l) + visibleWidth(r) + MIN_GAP > width && visibleWidth(l) > 0)
		l = truncateToWidth(l, Math.max(0, visibleWidth(l) - 1), "");
	const gap = Math.max(0, width - 2 - visibleWidth(l) - visibleWidth(r));
	return `${fill("─")}${l}${fill("─".repeat(gap))}${r}${fill("─")}`;
}

// ─── session stats ───────────────────────────────────────────────────────────

function sessionStats(ctx: ExtensionContext): { input: number; output: number; cost: number } {
	let input = 0, output = 0, cost = 0;
	for (const e of ctx.sessionManager.getBranch()) {
		if (e.type === "message" && e.message.role === "assistant") {
			const m = e.message as AssistantMessage;
			input += m.usage.input;
			output += m.usage.output;
			cost += m.usage.cost.total;
		}
	}
	return { input, output, cost };
}

// ─── extension ───────────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
	let footerRepaint: (() => void) | null = null;
	let isWorking = false;
	let spinnerIdx = 0;
	let spinnerTimer: ReturnType<typeof setInterval> | undefined;
	let activeTui: TUI | undefined;
	let currentBranch: string | null = null;

	// Geometry dot ramp - carries motion through shape, not color noise
	const SPINNER = ["·", "∘", "◦", "○", "◎", "●", "◎", "○", "◦", "∘"];

	const stopSpinner = () => {
		if (spinnerTimer) { clearInterval(spinnerTimer); spinnerTimer = undefined; }
	};

	pi.on("agent_start", () => {
		isWorking = true;
		stopSpinner();
		spinnerTimer = setInterval(() => {
			spinnerIdx = (spinnerIdx + 1) % SPINNER.length;
			activeTui?.requestRender();
		}, 90);
		activeTui?.requestRender();
	});

	pi.on("agent_end", () => {
		isWorking = false;
		stopSpinner();
		activeTui?.requestRender();
		footerRepaint?.();
	});

	pi.on("model_select", () => {
		activeTui?.requestRender();
		footerRepaint?.();
	});

	pi.on("session_shutdown", () => {
		stopSpinner();
		activeTui = undefined;
		footerRepaint = null;
	});

	pi.on("session_start", (_event, ctx) => {
		// Spinner is in the editor chrome - suppress the inline working indicator
		ctx.ui.setWorkingVisible(false);

		// Fetch branch once; refreshed when footer's onBranchChange fires
		const refreshBranch = async () => {
			const r = await pi.exec("git", ["branch", "--show-current"], { cwd: ctx.cwd }).catch(() => undefined);
			const b = r?.stdout.trim();
			currentBranch = b && b.length > 0 ? b : null;
			activeTui?.requestRender();
		};
		void refreshBranch();

		// ── Header: ◎ pi v<ver> ──────────────────────────────────────────────
		// ◎ in warning (yellow) - matches starship jetpack success char palette
		ctx.ui.setHeader((_tui, theme) => ({
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

		// ── Bordered editor ──────────────────────────────────────────────────
		// Top:    ─── ◎ pi ──── [spinner] ──────────────────────────────────
		// Bottom: ─ ⌂ dir  △ branch ──────────────── provider∷model  ctx% ─

		class JetpackEditor extends CustomEditor {
			constructor(tui: TUI, theme: EditorTheme, keybindings: KeybindingsManager) {
				super(tui, theme, keybindings, { paddingX: 0 });
				activeTui = tui;
			}

			render(width: number): string[] {
				const lines = super.render(width);
				if (lines.length < 2) return lines;

				const thm = ctx.ui.theme;
				const fill = (s: string) => this.borderColor(s);

				// Top border: brand on left, spinner on right while working
				const topLeft = ` ${thm.fg("warning", "◎")} ${thm.fg("accent", italic("pi"))} `;
				const topRight = isWorking
					? ` ${thm.fg("dim", italic(SPINNER[spinnerIdx] ?? "·"))} `
					: "";

				// Bottom border: cwd+branch on left, model+ctx on right
				const rawDir = process.cwd().replace(/\/+$/, "").split("/").slice(-2).join("/");
				const dir = rawDir.replace(process.env.HOME ?? "", "⌂");
				const branch = truncBranch(currentBranch);
				const dirPart = ` ${thm.fg("dim", italic(dir))} `;
				const branchPart = branch
					? `${thm.fg("accent", "△")} ${thm.fg("accent", italic(branch))} `
					: "";

				const model = ctx.model?.id ?? "no-model";
				const provider = ctx.model?.provider ?? "";
				const usage = ctx.getContextUsage();
				const ctxPct = usage?.percent != null ? `  ${thm.fg("dim", italic(`${Math.round(usage.percent)}%`))}` : "";
				const modelLabel = provider
					? `${thm.fg("dim", italic(`${provider}∷`))}${thm.fg("accent", italic(model))}`
					: thm.fg("accent", italic(model));
				const bottomRight = ` ${modelLabel}${ctxPct} `;

				lines[0] = fitBorder(topLeft, topRight, width, fill);
				lines[lines.length - 1] = fitBorder(
					dirPart + branchPart,
					bottomRight,
					width,
					fill,
				);
				return lines;
			}

			// Re-render when state outside the component changes
			invalidate(): void {
				super.invalidate();
			}
		}

		ctx.ui.setEditorComponent(
			(tui: TUI, theme: EditorTheme, keybindings: KeybindingsManager): CustomEditorType =>
				new JetpackEditor(tui, theme, keybindings),
		);

		// ── Footer: session stats ────────────────────────────────────────────
		// repo △ branch          ⎪ ▴in ▿out ◈cost ⎥  provider∷model
		ctx.ui.setFooter((tui, theme, footerData) => {
			footerRepaint = () => tui.requestRender();
			const unsubBranch = footerData.onBranchChange(() => {
				currentBranch = footerData.getGitBranch();
				activeTui?.requestRender();
				tui.requestRender();
			});

			return {
				dispose() {
					unsubBranch();
					footerRepaint = null;
				},
				invalidate() {},
				render(width: number): string[] {
					const { input, output, cost } = sessionStats(ctx);

					const repo = repoName();
					const branch = truncBranch(footerData.getGitBranch());
					const provider = ctx.model?.provider ?? null;
					const modelId = ctx.model?.id ?? "no-model";

					// Left: repo (accent bold)  △ branch (accent italic)
					const leftParts: string[] = [];
					if (repo) leftParts.push(theme.fg("accent", theme.bold(repo)));
					if (branch) {
						leftParts.push(
							`${theme.fg("accent", italic("△"))} ${theme.fg("accent", italic(branch))}`,
						);
					}
					const left = leftParts.join("  ");

					// Right: ⎪ ▴in ▿out ◈cost ⎥  provider∷model
					// Brackets dim, token counts accent, cost error (money out)
					const hasCost = input > 0 || output > 0 || cost > 0;
					const statsParts: string[] = [];
					if (hasCost) {
						statsParts.push(theme.fg("dim", italic("⎪")));
						statsParts.push(theme.fg("accent", italic(`▴${fmtTokens(input)}`)));
						statsParts.push(theme.fg("accent", italic(`▿${fmtTokens(output)}`)));
						statsParts.push(theme.fg("error", italic(`◈${fmtCost(cost)}`)));
						statsParts.push(theme.fg("dim", italic("⎥")));
					}
					const modelLabel = provider
						? `${theme.fg("dim", italic(`${provider}∷`))}${theme.fg("accent", italic(modelId))}`
						: theme.fg("accent", italic(modelId));
					const right = [...statsParts, modelLabel].join("  ");

					const gap = Math.max(1, width - visibleWidth(left) - visibleWidth(right) - PAD.length * 2);
					return [truncateToWidth(`${PAD}${left}${" ".repeat(gap)}${right}${PAD}`, width)];
				},
			};
		});
	});
}
