require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Show active LSP clients
map("n", "<leader>li", function()
  local clients = vim.lsp.get_clients { bufnr = 0 }
  if #clients == 0 then
    vim.notify("No LSP clients active", vim.log.levels.WARN)
    return
  end
  local names = {}
  for _, c in ipairs(clients) do
    table.insert(names, c.name)
  end
  vim.notify("LSP: " .. table.concat(names, ", "), vim.log.levels.INFO)
end, { desc = "List active LSP clients" })

-- Peek the definition source in a floating window (without jumping to it)
local function peek_definition()
  local params = vim.lsp.util.make_position_params(0, "utf-8")
  vim.lsp.buf_request(0, "textDocument/definition", params, function(_, result)
    if not result or vim.tbl_isempty(result) then
      vim.notify("No definition found", vim.log.levels.WARN)
      return
    end

    local target = vim.islist(result) and result[1] or result
    local uri = target.uri or target.targetUri
    local range = target.range or target.targetSelectionRange
    local bufnr = vim.uri_to_bufnr(uri)
    vim.fn.bufload(bufnr)

    -- grab ~16 lines of context starting at the definition
    local start_line = range.start.line
    local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, start_line + 16, false)

    local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
    local float_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, lines)
    vim.api.nvim_set_option_value("filetype", ft, { buf = float_buf })

    local width = 0
    for _, l in ipairs(lines) do
      width = math.max(width, #l)
    end

    vim.lsp.util.open_floating_preview(lines, ft, {
      border = "rounded",
      width = math.min(math.max(width, 40), 100),
      title = " Definition: " .. vim.fn.fnamemodify(vim.uri_to_fname(uri), ":t") .. " ",
    })
  end)
end

map("n", "<leader>pd", peek_definition, { desc = "LSP peek definition (floating preview)" })

-- Auto-show hover docs when the cursor rests on a symbol.
-- Toggle off any time with :lua vim.b.auto_hover = false
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    if vim.b.auto_hover == false then
      return
    end
    -- don't trigger while a float (e.g. completion/hover) is already open
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_config(win).relative ~= "" then
        return
      end
    end
    local ok = pcall(vim.lsp.buf.hover, { focusable = false, border = "rounded" })
    if not ok then
      return
    end
  end,
})

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
