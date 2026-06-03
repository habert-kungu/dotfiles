local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "isort", "black" },
    -- web: try prettierd (daemon, fast) then fall back to prettier
    javascript = { "prettierd", "prettier", stop_after_first = true },
    javascriptreact = { "prettierd", "prettier", stop_after_first = true },
    typescript = { "prettierd", "prettier", stop_after_first = true },
    typescriptreact = { "prettierd", "prettier", stop_after_first = true },
    svelte = { "prettierd", "prettier", stop_after_first = true },
    css = { "prettierd", "prettier", stop_after_first = true },
    scss = { "prettierd", "prettier", stop_after_first = true },
    html = { "prettierd", "prettier", stop_after_first = true },
    json = { "prettierd", "prettier", stop_after_first = true },
    jsonc = { "prettierd", "prettier", stop_after_first = true },
    yaml = { "prettierd", "prettier", stop_after_first = true },
    markdown = { "prettierd", "prettier", stop_after_first = true },
    go = { "goimports", "gofumpt" },
    c = { "clang-format" },
    cpp = { "clang-format" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    rust = { "rustfmt" },
    java = { "google-java-format" },
    -- LSP-only formatting (no standalone formatter configured) is handled by
    -- the lsp_format = "fallback" option below.
  },

  -- Format on save; fall back to the LSP formatter when no formatter is configured
  format_on_save = {
    -- generous timeout so a cold formatter (e.g. prettierd daemon spin-up,
    -- first black/isort run) still completes on the first save
    timeout_ms = 3000,
    lsp_format = "fallback",
  },
}

return options
