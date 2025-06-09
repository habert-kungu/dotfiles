-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v2.5/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "gruvchad",
  transparency = true,
  theme_toggle = { "chocolate", "gruvchad" },
  hl_override = {
    StatusLine = { bg = "#222222", fg = "#bbbbbb" },
    StatusLineNC = { bg = "#222222", fg = "#888888" },
    Comment = { italic = true },
    ["@comment"] = { italic = true },
  },
}

M.ui = {
  -- theme = "gruvchad_custom",
  statusline = {
    theme = "vscode_colored",
    separator_style = "block",
  },
}

return M
