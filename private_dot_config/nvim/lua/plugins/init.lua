return {
	{
		"stevearc/conform.nvim",
		event = "BufWritePre", -- uncomment for format on save
		config = function()
			require("configs.conform")
		end,
	},

	-- LeetCode plugin
	{
		"kawre/leetcode.nvim",
		build = ":TSUpdate html",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
		},
		opts = {
			-- configuration goes here
		},
	},
	{ "wakatime/vim-wakatime", lazy = false },

	{
		"neovim/nvim-lspconfig",
		config = function()
			require("nvchad.configs.lspconfig").defaults()
			require("configs.lspconfig")
		end,
	},
	--Mason
	{
		"mason-org/mason.nvim",
		opts = {
			ensure_installed = {
				"lua-language-server",
				"stylua",
				"html-lsp",
				"css-lsp",
				"pyright",
				"black",
				"debugpy",
				"mypy",
				"ruff",
				"ruff-lsp",
				"pyright",
				"clangd",
				"clang-format",
				"eslint-lsp",
				"prettierd",
				"tailwindcss-language-server",
				"ts_ls",
			},
		},
	},
	--treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		opts = {
			indent = { enable = true },
			highlight = { enable = true },
			auto_install = true,
		},
	},
	--nvim-lint for linting
	{
		"nvimtools/none-ls.nvim",
		event = "VeryLazy",
		opts = function()
			return require("configs.null-ls")
		end,
	},
	{
		"windwp/nvim-ts-autotag",
		ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	},
	{
		"christoomey/vim-tmux-navigator",
		cmd = {
			"TmuxNavigateLeft",
			"TmuxNavigateDown",
			"TmuxNavigateUp",
			"TmuxNavigateRight",
			"TmuxNavigatePrevious",
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