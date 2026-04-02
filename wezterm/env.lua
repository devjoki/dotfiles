local wezterm = require("wezterm")

local M = {}

local cached_key = nil

function M.setup(config)
	-- Fetch Anthropic API key from keychain once when WezTerm starts
	-- Uses a module-level cache so manual config reloads (CMD+SHIFT+P) don't re-prompt

	if not wezterm.target_triple:find("darwin") then
		return
	end

	if not cached_key then
		local success, stdout, stderr = wezterm.run_child_process({
			"security",
			"find-generic-password",
			"-s",
			"anthropic-api-key",
			"-w",
		})
		if success then
			cached_key = stdout:gsub("%s+$", "")
		end
	end

	if cached_key then
		config.set_environment_variables = config.set_environment_variables or {}
		config.set_environment_variables.ANTHROPIC_API_KEY = cached_key
	end
end

return M
