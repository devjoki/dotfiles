local M = {}
local wezterm = require("wezterm")
local act = wezterm.action
local sessions = wezterm.plugin.require("https://github.com/abidibo/wezterm-sessions")

sessions.apply_to_config({}, {
	auto_save_interval_s = 30,
	git_branch_warn = true,
	save_state_dir = "default-user-owned",
})

wezterm.on("gui-startup", function()
	local _, _, window = wezterm.mux.spawn_window({})
	wezterm.time.call_after(0.5, function()
		window:gui_window():perform_action(act({ EmitEvent = "load_session" }), window:gui_window():active_pane())
	end)
end)

M.keys = {
	{ key = "s", mods = "LEADER", action = act({ EmitEvent = "save_session" }) },
	{ key = "l", mods = "LEADER", action = act({ EmitEvent = "load_session" }) },
	{ key = "r", mods = "LEADER", action = act({ EmitEvent = "restore_session" }) },
	{ key = "d", mods = "LEADER", action = act({ EmitEvent = "delete_session" }) },
	{ key = "e", mods = "LEADER", action = act({ EmitEvent = "edit_session" }) },
	{ key = "a", mods = "LEADER", action = act({ EmitEvent = "toggle_autosave" }) },
	{ key = "f", mods = "LEADER", action = act({ EmitEvent = "fork_session" }) },
}

return M
