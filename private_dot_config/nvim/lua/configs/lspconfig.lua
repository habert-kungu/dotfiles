local lspconfig = require "lspconfig"
local lsp_utils = require "nvchad.configs.lspconfig"

local on_attach = lsp_utils.on_attach
local on_init = lsp_utils.on_init
local capabilities = lsp_utils.capabilities

-- Default LSP server setup
local default_servers = { "html", "cssls", "gopls", "ruff", "pyright", "ts_ls", "eslint" }

for _, lsp in ipairs(default_servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  }
end
-- setup for go
lspconfig.gopls.setup {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gompl" },
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

-- Custom HTML LSP setup
lspconfig.html.setup {
  opts = {
    root_dir = function(fname)
      return lspconfig.util.root_pattern ".git"(fname) or lspconfig.util.path.dirname(fname)
    end,
    filetypes = { "html", "htmldjango" },
  },
  on_attach = on_attach, -- Add on_attach for consistency
  on_init = on_init,
  capabilities = capabilities,
}

-- Custom Python LSP setup (Pyright)
lspconfig.pyright.setup {
  settings = {
    pyright = {
      disableOrganizeImports = true, -- Using Ruff's import organizer
    },
    python = {
      analysis = {
        ignore = { "*" }, -- Exclusively use Ruff for linting
      },
    },
  },
  on_attach = on_attach, -- Add on_attach for consistency
  on_init = on_init,
  capabilities = capabilities,
}

-- Custom Ruff LSP on_attach
local function custom_ruff_on_attach(client, bufnr)
  if client.name == "ruff_lsp" then
    client.server_capabilities.hoverProvider = false -- Disable hover in favor of Pyright
  end
  on_attach(client, bufnr) -- Call the original on_attach
end

-- Custom Clangd LSP setup
lspconfig.clangd.setup {
  on_attach = function(client, bufnr)
    client.server_capabilities.signatureHelpProvider = false
    custom_ruff_on_attach(client, bufnr) -- Use custom ruff on_attach
  end,
  capabilities = capabilities,
}
