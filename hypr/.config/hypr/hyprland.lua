-- Hyprland config

-- Theme: Catppuccin Mocha
local colors = require("themes.catppuccin-mocha")

--------------------
---- MONITORS   ----
--------------------

local main_mon = "DP-3" -- main monitor (landscape)
local side_mon = "DP-2" -- side monitor (portrait)

hl.monitor({ output = main_mon, mode = "preferred", position = "0x0", scale = 1 })
hl.monitor({ output = side_mon, mode = "preferred", position = "-1440x-520", scale = 1, transform = 3, vrr = 0 })
-- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- Each monitor owns its own numbered workspaces, bound to that output:
--   1..4 -> main monitor, 5..8 -> side monitor
-- for i = 1, 4 do
-- 	hl.workspace_rule({ workspace = tostring(i), monitor = main_mon, default = (i == 1) })
-- 	hl.workspace_rule({ workspace = tostring(i + 4), monitor = side_mon, default = (i == 1) })
-- end

-- Dedicated workspace for World of Warcraft, pinned to the main monitor.
hl.workspace_rule({ workspace = "name:WoW", monitor = main_mon })

--------------------
---- ENV VARS   ----
--------------------

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("XCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

--------------------
---- AUTOSTART  ----
--------------------

hl.on("hyprland.start", function()
	hl.exec_cmd("systemctl --user start hyprpolkitagent.service")
	-- Waybar supervisor: keep exactly ONE instance alive and self-heal on crash.
	-- Waybar SIGSEGVs at boot when it races Hyprland IPC/outputs coming up, and can
	-- die later too. `pkill -x waybar` first guarantees a single bar (no stacking);
	-- the loop respawns waybar whenever it exits. Backoff doubles 1->8s while it keeps
	-- crashing fast and resets after a healthy run (>=10s uptime), so a broken config
	-- backs off instead of busy-spinning -- and recovers on its own once fixed.
	-- Reload config/style: `killall -SIGUSR2 waybar`. Restart: `killall waybar`
	-- (the loop respawns one clean instance) -- do NOT launch `waybar` by hand.
	hl.exec_cmd("bash -c 'pkill -x waybar 2>/dev/null; d=1; while true; do t=$SECONDS; waybar; if [ $((SECONDS-t)) -ge 10 ]; then d=1; else d=$(( d<8 ? d*2 : 8 )); fi; sleep $d; done'")
	hl.exec_cmd("swaync")
	hl.exec_cmd("awww-daemon")
	hl.exec_cmd("sleep 1 && awww img -o DP-3 ~/Pictures/Wallpapers/cyberpunk_landscape.jpg")
	hl.exec_cmd("sleep 1 && awww img -o DP-2 ~/Pictures/Wallpapers/cyberpunk_portrait.jpg")
	hl.exec_cmd("wl-paste --watch cliphist store")
	hl.exec_cmd("nm-applet --indicator")
	-- XEmbed->SNI bridge so Wine/Battle.net tray icons show in waybar's tray.
	-- The `sleep 2` is required: started immediately it races Xwayland startup
	-- (it's an X11 client) and exits, leaving Battle.net's tray icon orphaned.
	hl.exec_cmd("sleep 2 && xembedsniproxy")
	hl.exec_cmd("/usr/lib/xdg-desktop-portal-hyprland")
	hl.exec_cmd("sleep 1 && /usr/lib/xdg-desktop-portal --replace")
	hl.exec_cmd("elephant")
	hl.exec_cmd("sleep 2 && walker --gapplication-service")
end)

--------------------
---- CONFIG     ----
--------------------

hl.config({
	input = {
		kb_layout = "us",
		follow_mouse = 1,
		numlock_by_default = true,

		-- MOUSE -----------------------------------------------------------
		sensitivity = 0,
		accel_profile = "flat",

		-- natural_scroll: invert wheel direction (false = traditional).
		natural_scroll = false,

		-- scroll_factor: multiplier for wheel scroll distance (1.0 = default).
		scroll_factor = 1.0,

		-- left_handed: swap left/right mouse buttons.
		left_handed = false,

		touchpad = {
			natural_scroll = false,
		},
		---------------------------------------------------------------------
	},

	general = {
		gaps_in = 4,
		gaps_out = 4,
		border_size = 1,
		layout = "dwindle",
		col = {
			-- Gradients are a table of rgb(...)/rgba(...) colors + an angle.
			-- colors.* are already in rgb(...) format.
			-- active_border = { colors = { colors.mauve, colors.blue }, angle = 45 },
			-- active_border = { colors = { "rgb(ff2ed6)", "rgb(00e5ff)" }, angle = 45 },
			-- active_border = { colors = { "rgb(ff2ed6)", "rgb(ff2ed6)", "rgb(00e5ff)", "rgb(00e5ff)" }, angle = 45 },
			-- Solid neon cyan, no gradient.
			active_border = { colors = { "rgb(00e5ff)" } },
			inactive_border = colors.surface0,
		},
	},

	decoration = {
		rounding = 4,
		blur = {
			enabled = true,
			size = 3,
			passes = 1,
		},
	},

	animations = {
		enabled = true,
	},

	dwindle = {
		preserve_split = true,
	},

	misc = {
		vrr = 1,
		disable_hyprland_logo = true,
		focus_on_activate = true,
	},
	cursor = {
		no_warps = true,
	},
})

------------------------
---- WINDOW RULES   ----
------------------------

-- Make the tiny Wine/XEmbed systray icon windows (empty class+title, 32x32,
-- XWayland) invisible IN PLACE. xembedsniproxy proxies them to the waybar tray,
-- but the underlying X11 icon window re-shows on click as a black box. opacity 0
-- + no_blur are DYNAMIC rules that keep it invisible every time it reappears,
-- unlike a workspace/special rule which only applies once at window creation.
hl.window_rule({
	name = "hide-wine-tray-bar",
	match = {
		class = "^$",
		title = "^$",
		float = true,
		xwayland = true,
	},
	opacity = 0.0,
	no_blur = true,
	no_focus = true,
})

-- World of Warcraft (Wine/Proton, class steam_app_default, title "World of
-- Warcraft"). Force real fullscreen so it gets the FULL monitor (2560x1440)
-- instead of the tiled usable area (2540x1376, shrunk by waybar's exclusive
-- zone + gaps_out). Without this, WoW in windowed-fullscreen and the tiler
-- fight over the size mismatch and the window snaps/resizes endlessly.
hl.window_rule({
	name = "wow-fullscreen",
	match = {
		class = "steam_app_default",
		title = "^World of Warcraft$",
	},
	workspace = "name:WoW",
	fullscreen = true,
})

-- Snip editor (Super+Shift+S) floats instead of tiling.
hl.window_rule({
	name = "swappy-float",
	match = {
		class = "^swappy$",
	},
	float = true,
})

--------------------
----  PROGRAMS  ----
--------------------
local terminal = "ghostty"
local fileManager = "nemo"
local browser = "brave"
local music = "flatpak run com.spotify.Client"
local notes = "obsidian"
local launcher = "walker"

--------------------
---- BINDINGS   ----
--------------------

local mod = "SUPER"
local mod2 = "SUPER + SHIFT"
local mod3 = "ALT"
local mod4 = "ALT + SHIFT"
local mod5 = "SUPER + ALT"

hl.bind(mod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mod .. " + M", hl.dsp.exec_cmd(music))
hl.bind(mod .. " + N", hl.dsp.exec_cmd(notes))
hl.bind(mod .. " + Space", hl.dsp.exec_cmd(launcher))

hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod2 .. " + Q", hl.dsp.exit())

-- Toggle floating, EXCEPT World of Warcraft (see fullscreen bind below).
hl.bind(mod .. " + V", function()
	local w = hl.get_active_window()
	if w and w.title and w.title:match("World of Warcraft") then
		return
	end
	hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
end)

-- Toggle fullscreen on the focused window, EXCEPT World of Warcraft. WoW manages
-- its own windowed-fullscreen; toggling the compositor's fullscreen makes it
-- fight the tiler and snap/break (see the wow-fullscreen window rule above).
hl.bind(mod .. " + F", function()
	local w = hl.get_active_window()
	if w and w.title and w.title:match("World of Warcraft") then
		return
	end
	hl.dispatch(hl.dsp.window.fullscreen())
end)

-- Media keys ----------------------------------------------------------------
-- locked = also fire while the screen is locked; repeating = key-repeat held.
-- Volume (-l 1.0 caps at 100% to avoid software over-amplification).
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
-- Nuphy Air75 V3 F24 key -> mic mute toggle (Discord "mute"). Discord can't grab
-- global hotkeys under native Wayland, so we mute the mic at the PipeWire source
-- instead. A descending/rising system chirp signals the state (Discord-style),
-- since Discord's own UI won't reflect the source mute.
hl.bind("F24", hl.dsp.exec_cmd(
	"wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle && "
	.. "if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED; "
	.. "then paplay /usr/share/sounds/freedesktop/stereo/device-removed.oga; "
	.. "else paplay /usr/share/sounds/freedesktop/stereo/device-added.oga; fi"
), { locked = true })
-- Playback (works with any MPRIS player: Spotify, browsers, mpv, etc.)
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- hl.bind(mod .. " + P", hl.dsp.window.pseudo())
hl.bind(mod .. " + P", hl.dsp.layout("togglesplit"))

-- Screenshots
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m output"))
hl.bind(mod .. " + Print", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind(mod2 .. " + S", hl.dsp.exec_cmd("/home/phill/.config/hypr/scripts/snip.sh")) -- Windows-style snip

-- Mouse window management
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Focus switching ---------------------------------------------------------
-- Vim keys
hl.bind(mod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + L", hl.dsp.focus({ direction = "right" }))

-- Alt+Tab
hl.bind(mod3 .. " + Tab", hl.dsp.window.cycle_next())

-- Workspaces ----------------------------------------------------------------
package.path = package.path .. ";./?.lua;./?/init.lua"
local smw = require("plugins.split-monitor-workspaces")

smw.setup({
    workspace_count = 10,
	monitor_priority = { main_mon, side_mon },
	max_workspaces = { ["DP-2"] = 3 },
	keep_focused = true,
	enable_wrapping = true,
	link_monitors = false,
	enable_persistent_workspaces = false,
})

for i = 1, smw.get_amount_of_workspaces() do
    local n = tostring(i)
    if n == "10" then n = "0" end -- Optional if you configured 10 workspaces: bind workspace 10 to SUPER + 0
    -- Switch to the Nth workspace on the currently focused monitor.
    hl.bind(mod .. " +" .. n, smw.workspace(n))
    -- Move the active window to the Nth workspace on the currently focused monitor silently (no focus change).
    hl.bind(mod2 .. " +" .. n, smw.move_to_workspace_silent(n))
end

--- Cycle workspaces on the current monitor.
hl.bind(mod .. " + mouse_down", smw.cycle_workspaces("prev"))
hl.bind(mod .. " + mouse_up", smw.cycle_workspaces("next"))

--- Move orphaned windows (not assigned to any mapped workspace) to the current workspace.
hl.bind(mod2 .. " + G", smw.grab_rogue_windows())



------------------------------------------------------------------------------
---------
---------
-- OLD --
---------
---------
-- Workspaces: SUPER+1..4 -> main monitor (ws 1-4), SUPER+CTRL+1..4 -> side monitor (ws 5-8).
-- Add SHIFT to move the focused window to that workspace.
-- for i = 1, 4 do
-- 	hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = tostring(i) }))
-- 	hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = tostring(i) }))
-- 	hl.bind(mod .. " + CTRL + " .. i, hl.dsp.focus({ workspace = tostring(i + 4) }))
-- 	hl.bind(mod .. " + CTRL + SHIFT + " .. i, hl.dsp.window.move({ workspace = tostring(i + 4) }))
-- end

-- i use arch btw
