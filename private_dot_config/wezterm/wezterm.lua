local wezterm = require 'wezterm'

return {
  -- General settings
  -- font = wezterm.font("JetBrains Mono"),
  font_size = 14,
  color_scheme = "Gruvbox Dark Hard", -- Fallback
  hide_tab_bar_if_only_one_tab = true,
  enable_scroll_bar = false,
  window_decorations = "NONE", -- No title bar (i3)
  adjust_window_size_when_changing_font_size = false,

  -- Darker Gruvbox with grep-friendly contrast
  colors = {
    foreground = "#ebdbb2",
    background = "#0D0F10",
    cursor_bg = "#ebdbb2",
    cursor_fg = "#0D0F10",
    cursor_border = "#ebdbb2",
    selection_bg = "#458588", -- Brighter blue for selections (grep highlights)
    selection_fg = "#ebdbb2",
    ansi = {
      "#0D0F10", -- Black
      "#cc241d", -- Red
      "#98971a", -- Green
      "#d79921", -- Yellow
      "#458588", -- Blue (now used for selections)
      "#b16286", -- Magenta
      "#689d6a", -- Cyan
      "#a89984", -- White
    },
    brights = {
      "#928374",
      "#fb4934",
      "#b8bb26",
      "#fabd2f",
      "#83a598", -- Bright Blue (alternative for highlights)
      "#d3869b",
      "#8ec07c",
      "#ebdbb2",
    },
  },

  -- Disable cursor blink to avoid distractions during grep
  default_cursor_style = "SteadyBlock",
  cursor_blink_rate = 0,

  -- Window settings
  window_padding = {
    left = 5,
    right = 5,
    top = 5,
    bottom = 5,
  },
  window_background_opacity = 1.0, -- Disable transparency for reliability
  text_background_opacity = 1.0,
}
