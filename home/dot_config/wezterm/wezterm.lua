local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.automatically_reload_config = true
config.use_ime = true
config.adjust_window_size_when_changing_font_size = false
config.use_cap_height_to_scale_fallback_fonts = true
config.macos_forward_to_ime_modifier_mask = 'SHIFT|CTRL'
config.color_scheme = 'Dark Pastel'
config.font = wezterm.font({ family = "Monaspace Neon", weight = "Regular", stretch = "Normal", italic = false })
config.font_size = 14.0
config.command_palette_font_size = 14.0
config.default_cursor_style = 'BlinkingBlock'
config.enable_scroll_bar = true
config.scrollback_lines = 65536
config.macos_window_background_blur = 20
config.window_background_opacity = 0.8
config.window_padding = { left = 4, right = 4, top = 4, bottom = 4 }
config.window_decorations = "RESIZE"
config.window_frame = { active_titlebar_bg = "none", inactive_titlebar_bg = "none" }
config.window_background_gradient = { colors = { "#000000" }}
config.show_tabs_in_tab_bar = true

wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = wezterm.mux.spawn_window(cmd or { width=256, height=64 })
  window:gui_window():set_position(0,0)
end)

return config
