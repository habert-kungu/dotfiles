require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

-- map('n', ':', '<cmd>FineCmdline<CR>', {noremap = true})
-- vim.api.nvim_set_keymap("n", ":", "<cmd>FineCmdline<CR>", { noremap = true })
map("n", ";", ":", { desc = "CMD enter command mode" })
-- Define the jk escape mapping in your desired insert mode keymap
vim.api.nvim_set_keymap("i", "<jk>", "<ESC>", {})
map("i", "jk", "<ESC>")
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
