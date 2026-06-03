return {
  -- Conform: run standalone formatters (stylua, black, isort, prettier, ...)
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = function()
      return require "configs.conform"
    end,
  },

  -- Mason: install formatters & linters (mason PACKAGE names)
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    opts = {
      ensure_installed = {
        "stylua", "prettierd", "prettier", "black", "isort",
        "clang-format", "gofumpt", "goimports", "shfmt",
        "google-java-format",
      },
    },
  },

  -- mason-lspconfig: auto-install & auto-enable installed LSP servers
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      -- NOTE: ensure_installed here uses LSPCONFIG SERVER NAMES (not mason
      -- package names) — required by mason-lspconfig v2.
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls", "pyright", "ruff", "gopls", "rust_analyzer",
          "clangd", "ts_ls", "html", "cssls", "eslint",
          "jdtls", "jsonls", "yamlls", "bashls",
          "dockerls", "marksman",
        },
        -- auto-enable every installed server EXCEPT stylua, which ships a niche
        -- `stylua --lsp` server we don't want (stylua is used via conform only).
        automatic_enable = { exclude = { "stylua" } },
      })
    end,
  },

  -- Extend NvChad's lspconfig (load on opening a file)
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    config = function()
      require("lspconfig")
      require("nvchad.configs.lspconfig").defaults()
      require("configs.lspconfig")
    end,
  },

  -- Treesitter (main branch — required by NvChad v2.5 & Neovim 0.12; parsers
  -- are compiled with the `tree-sitter` CLI. Highlighting is enabled by
  -- NvChad's FileType autocmd via vim.treesitter.start()).
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    opts = {
      ensure_installed = {
        "lua", "luadoc", "vim", "vimdoc", "query", "printf",
        "python", "go", "gomod", "gosum", "javascript", "typescript",
        "tsx", "rust", "c", "cpp", "java", "json", "jsonc", "yaml",
        "bash", "markdown", "markdown_inline", "html", "css",
      },
    },
  },

  -- Tmux navigator
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp",
      "TmuxNavigateRight", "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },
}
