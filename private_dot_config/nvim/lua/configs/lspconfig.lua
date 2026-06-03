local lsp_utils = require "nvchad.configs.lspconfig"

local on_attach = lsp_utils.on_attach

-- gopls
vim.lsp.config.gopls = {
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      analysis = {
        unusedParams = true,
      },
    },
  },
}

-- pyright
vim.lsp.config.pyright = {
  settings = {
    pyright = {
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        ignore = { "*" },
      },
    },
  },
}

-- html with custom filetypes
vim.lsp.config.html = {
  filetypes = { "html", "htmldjango" },
}

-- clangd with custom on_attach
vim.lsp.config.clangd = {
  on_attach = function(client, bufnr)
    client.server_capabilities.signatureHelpProvider = false
    if client.name == "ruff" then
      client.server_capabilities.hoverProvider = false
    end
    on_attach(client, bufnr)
  end,
}

-- Format on save via LSP
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    local clients = vim.lsp.get_clients { bufnr = args.buf }
    if #clients > 0 then
      vim.lsp.buf.format { bufnr = args.buf, timeout_ms = 1000 }
    end
  end,
})
