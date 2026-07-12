import type { ExtensionAPI, ExtensionContext, Theme } from "@earendil-works/pi-coding-agent";
import { VERSION } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import { execSync } from "node:child_process";
import { basename } from "node:path";

const LOGO = [
	"      ████████████    ",
	"      ████████████    ",
	"      ████    ████    ",
	"      ████    ████    ",
	"      ████████    ████",
	"      ████████    ████",
	"      ████        ████",
	"      ████        ████",
] as const;

const TITLE_TEXT = "pi coding agent";
type Colors = {
	accent: (text: string) => string;
	dim: (text: string) => string;
	text: (text: string) => string;
};

function compactCwd(cwd: string): string {
	const home = process.env.HOME;
	return home && cwd.startsWith(home) ? cwd.replace(home, "~") : cwd;
}

function projectName(cwd: string): string {
	return basename(cwd) || "session";
}

function userName(): string {
	return process.env.USER || process.env.LOGNAME || "user";
}

function localRepoName(cwd: string): string {
	try {
		const root = execSync("git rev-parse --show-toplevel", {
			cwd,
			encoding: "utf8",
			stdio: ["ignore", "pipe", "ignore"],
			timeout: 250,
		}).trim();
		return projectName(root);
	} catch {
		return projectName(cwd);
	}
}

const repoCache = new Map<string, string>();

function parseGithubRepo(remote: string): string | undefined {
	const match = remote.trim().match(/github\.com[:/]([^/\s]+)\/([^/\s#?]+?)(?:\.git)?(?:[#?].*)?$/);
	if (!match) return undefined;
	const owner = match[1];
	const repo = match[2].replace(/\.git$/, "");
	return owner && repo ? `${owner}/${repo}` : undefined;
}

function githubRepo(cwd: string): string {
	const cached = repoCache.get(cwd);
	if (cached) return cached;
	let repo: string | undefined;
	try {
		const remote = execSync("git config --get remote.origin.url", {
			cwd,
			encoding: "utf8",
			stdio: ["ignore", "pipe", "ignore"],
			timeout: 250,
		});
		repo = parseGithubRepo(remote);
	} catch {
		// Not a git repository or no origin remote.
	}
	repo ??= `${userName()}/${localRepoName(cwd)}`;
	repoCache.set(cwd, repo);
	return repo;
}

function padAnsi(text: string, width: number): string {
	return text + " ".repeat(Math.max(0, width - visibleWidth(text)));
}

function fitLine(line: string, width: number): string {
	return visibleWidth(line) > width ? truncateToWidth(line, width) : line;
}

function labelValue(label: string, value: string, color: Colors): string {
	return `${color.dim(padAnsi(label, 7))} ${color.text(value)}`;
}

function commandBrief(theme: Theme): string {
	const key = (text: string) => theme.fg("accent", text);
	const sep = theme.fg("dim", " · ");
	return [
		`${key("esc")} interrupt`,
		`${key("ctrl+c/ctrl+d")} clear/exit`,
		`${key("/")} commands`,
		`${key("!")} bash`,
		`${key("ctrl+o")} more`,
	].join(sep);
}

function renderTitle(ctx: ExtensionContext, theme: Theme, width: number): string[] {
	const color: Colors = {
		accent: (text: string) => theme.fg("accent", text),
		dim: (text: string) => theme.fg("dim", text),
		text: (text: string) => theme.fg("text", text),
	};

	const cwd = ctx.cwd ?? process.cwd();
	const logo = LOGO.map((line) => theme.bold(color.accent(line)));
	const logoWidth = Math.max(...LOGO.map((line) => visibleWidth(line)));
	const gap = width >= 72 ? "    " : "  ";
	const infoWidth = Math.max(0, width - logoWidth - visibleWidth(gap));
	const title = `${theme.bold(color.accent("π"))} ${theme.bold(color.text(TITLE_TEXT))}`;
	const titleRule = color.dim("─".repeat(visibleWidth(`${TITLE_TEXT}  `)));
	const info = [
		title,
		titleRule,
		labelValue("version", `v${VERSION}`, color),
		labelValue("model", ctx.model?.id ?? "no model", color),
		labelValue("dir", compactCwd(cwd), color),
		labelValue("repo", githubRepo(cwd), color),
		labelValue("user", userName(), color),
	];

	const blockLines = logo.map((logoLine, index) => {
		const infoLine = info[index] ?? "";
		return fitLine(`${padAnsi(logoLine, logoWidth)}${gap}${fitLine(infoLine, infoWidth)}`, width);
	});

	return ["", ...blockLines, "", fitLine(commandBrief(theme), width), ""].map((line) => fitLine(line, width));
}

function setTitleHeader(ctx: ExtensionContext): boolean {
	if (ctx.mode !== "tui") return false;

	ctx.ui.setHeader((_tui, theme) => ({
		render: (width: number) => renderTitle(ctx, theme, width),
		invalidate() {},
	}));

	return true;
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		setTitleHeader(ctx);
	});

	pi.on("resources_discover", (_event, ctx) => {
		setTitleHeader(ctx);
	});

	pi.on("model_select", (_event, ctx) => {
		setTitleHeader(ctx);
	});

	pi.on("session_shutdown", (_event, ctx) => {
		if (ctx.hasUI) ctx.ui.setHeader(undefined);
	});
}
