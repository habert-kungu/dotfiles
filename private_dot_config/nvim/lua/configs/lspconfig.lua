local lsp_utils = require "nvchad.configs.lspconfig"

local on_attach = lsp_utils.on_attach

-- gopls
vim.lsp.config.gopls = {
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      analyses = {
        unusedparams = true,
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

-- ruff: let pyright own hover, ruff owns lint/fix
vim.lsp.config.ruff = {
  on_attach = function(client, bufnr)
    client.server_capabilities.hoverProvider = false
    on_attach(client, bufnr)
  end,
}

-- html with custom filetypes
vim.lsp.config.html = {
  filetypes = { "html", "htmldjango" },
}

-- clangd
vim.lsp.config.clangd = {
  on_attach = function(client, bufnr)
    client.server_capabilities.signatureHelpProvider = false
    on_attach(client, bufnr)
  end,
}

-- Nicer bordered floating windows for hover & signature help
vim.lsp.config("*", {
  on_attach = function(_, bufnr)
    vim.keymap.set("n", "K", function()
      vim.lsp.buf.hover { border = "rounded" }
    end, { buffer = bufnr, desc = "LSP hover (definition/docs)" })

    vim.keymap.set("n", "<leader>k", function()
      vim.lsp.buf.signature_help { border = "rounded" }
    end, { buffer = bufnr, desc = "LSP signature help" })
  end,
})
