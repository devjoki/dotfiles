function bind_app(name, key)
	hs.hotkey.bind({ "cmd", "shift" }, key, function()
		local app = hs.application.find(name, true)
		if not app then
			hs.application.launchOrFocus(name)
		else
			if app:isFrontmost() then
				app:hide()
			else
				app:activate()
			end
		end
	end)
end

bind_app("Google Chrome", "1")
bind_app("WezTerm", "2")
bind_app("Microsoft Teams", "3")

hs.loadSpoon("SpoonInstall")
-- spoon.SpoonInstall:andUse("ColorPicker")
-- spoon.SpoonInstall:andUse("Caffeine")

spoon.SpoonInstall:andUse("ArrangeDesktop")

-- Arrange Safari, Slack, and Teams with a hotkey
hs.hotkey.bind({ "cmd", "shift" }, "o", function()
	local screen = hs.screen.mainScreen()
	local frame = screen:frame()
	local half = frame.w / 2
	local apps = {
		{ name = "Microsoft Teams", frame = { x = frame.x, y = frame.y, w = half, h = frame.h } },
		{ name = "Safari",          frame = { x = frame.x + half, y = frame.y, w = half, h = frame.h / 2 } },
		{ name = "Slack",           frame = { x = frame.x + half, y = frame.y + frame.h / 2, w = half, h = frame.h / 2 } },
	}

	for _, entry in ipairs(apps) do
		local app = hs.application.find(entry.name, true)
		if app then
			spoon.ArrangeDesktop:_positionApp(app, entry.name, screen, entry.frame)
		else
			hs.application.launchOrFocus(entry.name)
		end
	end
end)
