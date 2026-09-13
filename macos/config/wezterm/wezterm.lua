local wezterm = require("wezterm")
local act = wezterm.action

return {
	color_scheme = "Catppuccin Mocha",
	enable_tab_bar = false,
	font_size = 16.5,
	font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Regular", stretch = "Normal", style = "Normal" }),
	macos_window_background_blur = 30,
	window_background_opacity = 0.80,
	window_decorations = "RESIZE",

	-- Left Option is Alt (LazyVim's Alt+j/k move lines); right Option still types accented characters.
	send_composed_key_when_left_alt_is_pressed = false,
	send_composed_key_when_right_alt_is_pressed = true,

	-- macOS text-editing gestures, translated into keys zsh and nvim already understand.
	-- Cmd+← sends Home instead of Ctrl+a, because Ctrl+a is the tmux prefix.
	-- Ctrl+h/j/k/l are left untouched so nvim window navigation works.
	keys = {
		{ key = "LeftArrow", mods = "CMD", action = act.SendKey({ key = "Home" }) },
		{ key = "RightArrow", mods = "CMD", action = act.SendKey({ key = "End" }) },
		{ key = "LeftArrow", mods = "OPT", action = act.SendKey({ key = "b", mods = "ALT" }) },
		{ key = "RightArrow", mods = "OPT", action = act.SendKey({ key = "f", mods = "ALT" }) },
		{ key = "Backspace", mods = "CMD", action = act.SendKey({ key = "u", mods = "CTRL" }) },
		{ key = "Backspace", mods = "OPT", action = act.SendKey({ key = "w", mods = "CTRL" }) },
	},

	mouse_bindings = {
		-- Cmd-click opens the link under the cursor (Ctrl-click is right-click on macOS)
		{
			event = { Up = { streak = 1, button = "Left" } },
			mods = "CMD",
			action = act.OpenLinkAtMouseCursor,
		},
	},
}
