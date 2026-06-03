return {
  -- Mason: formatters & linters
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    opts = {
      ensure_installed = {
        "stylua", "prettierd", "black", "isort", "clang-format", "gofumpt",
      },
    },
  },

  -- mason-lspconfig: auto-enable installed LSP servers (loads at startup, tiny cost)
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua-language-server", "pyright", "ruff", "gopls",
          "clangd", "ts_ls", "html-lsp", "css-lsp", "eslint-lsp",
          "svelte-ls", "jdtls", "json-lsp", "yaml-lsp", "bashls",
          "dockerls", "marksman", "tailwindcss-language-server",
        },
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

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      indent = { enable = true }, highlight = { enable = true },
      auto_install = true,
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
