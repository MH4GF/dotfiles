local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.automatically_reload_config = true

--config.color_scheme = 'Catppuccin Frappe'
config.color_scheme = 'DanQing (base16)'
config.font = wezterm.font_with_fallback({
  'JetBrains Mono',
  'Noto Sans CJK JP',
})
config.font_size = 15.0

-- 背景透過
config.window_background_opacity = 0.85
config.macos_window_background_blur = 20

-- タイトルバーを消す
config.window_decorations = "RESIZE"

-- タブの追加ボタンを消す
config.show_new_tab_button_in_tab_bar = false

config.keys = {
  { key = 'd', mods = 'CMD', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'CMD|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
}

return config

