local wezterm = require("wezterm")

local M = {}

function M.setup(config)
	-- Fetch Anthropic API key from keychain once when WezTerm starts
	-- Note: This will prompt for keychain password if you manually reload config (CMD+SHIFT+P)
	-- To avoid this, simply don't reload config manually - changes will apply on next restart

	-- Only run on macOS
	if wezterm.target_triple:find("darwin") then
		local success, stdout, stderr = wezterm.run_child_process({
			"security",
			"find-generic-password",
			"-s",
			"anthropic-api-key",
			"-w",
		})

		if success then
			config.set_environment_variables = config.set_environment_variables or {}
			config.set_environment_variables.ANTHROPIC_API_KEY = stdout:gsub("%s+$", "") -- trim trailing whitespace
		end
	end
end

return M
