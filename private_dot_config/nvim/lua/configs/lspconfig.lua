local lsp_utils = require "nvchad.configs.lspconfig"

local on_attach = lsp_utils.on_attach
local on_init = lsp_utils.on_init
local capabilities = lsp_utils.capabilities

-- Servers that need no custom config
local default_servers = { "html", "cssls", "ruff", "ts_ls", "eslint" }

for _, lsp in ipairs(default_servers) do
  vim.lsp.enable(lsp)
end

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
vim.lsp.enable("gopls")

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
vim.lsp.enable("pyright")

-- html with custom filetypes
vim.lsp.config.html = {
  filetypes = { "html", "htmldjango" },
}
vim.lsp.enable("html")

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
vim.lsp.enable("clangd")
