local wezterm = require("wezterm")

local M = {}

function M.setup(config)
	-- Fetch Anthropic API key from keychain once when WezTerm starts
	local success, stdout, stderr = wezterm.run_child_process({
		"security",
		"find-generic-password",
		"-s",
		"anthropic-api-key",
		"-w",
	})

	if success then
		config.set_environment_variables = {
			ANTHROPIC_API_KEY = stdout:gsub("%s+$", ""), -- trim trailing whitespace
		}
	end
end

return M
