local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local null_ls = require "null-ls"

local opts = {
  sources = {
    -- null_ls.builtins.diagnostics.djlint,
    null_ls.builtins.formatting.isort,
    null_ls.builtins.formatting.prettierd,
    null_ls.builtins.formatting.clang_format,
    null_ls.builtins.formatting.black,
    -- null_ls.builtins.diagnostics.mypy.with {
    --   ignore_missing_imports = true,
    -- },
  },

  on_attach = function(client, bufnr)
    if client.supports_method "textDocument/formatting" then
      -- Clear existing formatting autocmds for this buffer
      vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }

      -- Create autocmd to format on buffer write (before)
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format { bufnr = bufnr }
        end,
      })

      -- Add key mapping for manual formatting (optional)
      -- vim.api.nvim_set_keymap("n", "<leader>fm", function()
      --   vim.lsp.buf.format { bufnr = bufnr }
      -- end, { noremap = true })
    end
  end,
}
return opts
