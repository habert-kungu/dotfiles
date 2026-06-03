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

  -- mason-lspconfig: ensure LSP servers installed + auto-enable on file open
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua-language-server", "pyright", "ruff", "gopls",
          "clangd", "ts_ls", "html-lsp", "css-lsp", "eslint-lsp",
          "svelte-ls", "jdtls", "json-lsp", "yaml-lsp", "bashls",
          "dockerls", "marksman", "tailwindcss-language-server",
        },
      })
      require("configs.lspconfig")
    end,
  },

  -- Treesitter: syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      indent = { enable = true },
      highlight = { enable = true },
      auto_install = true,
    },
  },

  -- Tmux navigator: seamless pane switching
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
