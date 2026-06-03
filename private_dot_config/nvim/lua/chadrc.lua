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
    modules = {
      lsp = function()
        local clients = vim.lsp.get_clients()
        local names = {}
        for _, c in ipairs(clients) do
          local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)
          if c.attached_buffers[bufnr] then
            table.insert(names, c.name)
          end
        end
        if #names == 0 then return "" end
        return "%#St_Lsp#  " .. table.concat(names, " ")
      end,
    },
  },
}

return M
