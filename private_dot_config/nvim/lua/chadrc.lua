-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v2.5/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

-- Statusline glyphs, built by codepoint (Nerd Font) so the file stays ASCII.
local icons = {
  lsp = vim.fn.nr2char(0xf085), -- gear: original LSP icon
  pie = vim.fn.nr2char(0xf200), -- pie chart: formatter armed ("circle of a cut pie")
  check = vim.fn.nr2char(0xf00c), -- check: formatter just ran (flash)
}

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
        local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)

        -- LSP clients attached to this buffer (original gear icon)
        local names = {}
        for _, c in ipairs(vim.lsp.get_clients()) do
          if c.attached_buffers[bufnr] then
            table.insert(names, c.name)
          end
        end
        local out = ""
        if #names > 0 then
          out = "%#St_Lsp# " .. icons.lsp .. " " .. table.concat(names, " ")
        end

        -- Conform formatter(s) that will run on save for this buffer.
        -- Pie-chart icon when armed; flashes a check for ~1.5s after a save.
        local ok, conform = pcall(require, "conform")
        if ok then
          local lister = conform.list_formatters_to_run or conform.list_formatters
          local fnames = {}
          for _, f in ipairs(lister(bufnr)) do
            if f.available then
              table.insert(fnames, f.name)
            end
          end
          if #fnames > 0 then
            local icon = vim.b[bufnr].conform_flash and icons.check or icons.pie
            out = out .. " %#St_Lsp# " .. icon .. " " .. table.concat(fnames, ",")
          end
        end

        return out
      end,
    },
  },
}

return M
