local M = {}

M.base_16 = {
  base00 = "#282828",
  base01 = "#3c3836",
  base02 = "#504945",
  base03 = "#665c54",
  base04 = "#bdae93",
  base05 = "#d5c4a1",
  base06 = "#ebdbb2",
  base07 = "#fbf1c7",
  base08 = "#fb4934",
  base09 = "#fe8019",
  base0A = "#fabd2f",
  base0B = "#b8bb26",
  base0C = "#8ec07c",
  base0D = "#83a598",
  base0E = "#d3869b",
  base0F = "#d65d0e",
}

M.type = "dark"

-- Minimal polish_hl overrides for core syntax groups
M.polish_hl = {
  Comment = { fg = M.base_30.grey, italic = true }, -- Italic comments in grey
  Identifier = { fg = M.base_30.blue }, -- Variables in blue (#6d8dad)
  Function = { fg = M.base_30.vibrant_green }, -- Functions in vibrant green (#a9b665)
  ["@method"] = { fg = M.base_16.base0A }, -- Methods in yellow (#e0c080)
}

M = require("base46").override_theme(M, "gruvchad_custom")

return M
