function bind_app(name, key)
	hs.hotkey.bind({ "cmd", "shift" }, key, function()
		-- pass true for the second param to not pick up browser window titles
		-- and other oddities
		app = hs.application.find(name, true)
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

bind_app("WezTerm", "2")
bind_app("Google Chrome", "1")
bind_app("IntelliJ IDEA", "3")

hs.loadSpoon("SpoonInstall")
-- spoon.SpoonInstall:andUse("ColorPicker")
-- spoon.SpoonInstall:andUse("Caffeine")
