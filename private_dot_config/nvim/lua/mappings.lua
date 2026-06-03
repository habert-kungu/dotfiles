require("nvchad.mappings")

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

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
