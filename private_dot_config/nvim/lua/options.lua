require "nvchad.options"

-- add yours here!

-- Use system clipboard by default (yank/delete/paste sync with + register)
vim.opt.clipboard = "unnamedplus"

-- Auto-preview images when opening image files (uses WezTerm Kitty protocol)
vim.api.nvim_create_autocmd("BufRead", {
  group = vim.api.nvim_create_augroup("ImagePreview", { clear = true }),
  pattern = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.bmp", "*.svg", "*.ico" },
  callback = function(args)
    local file = vim.fn.expand("%:p")
    vim.api.nvim_buf_delete(args.buf, { force = true })
    vim.cmd("below split | terminal")
    local cmd = vim.fn.executable("wezterm") == 1
      and ("wezterm imgcat " .. vim.fn.shellescape(file) .. " && read -p ''")
      or ("viu " .. vim.fn.shellescape(file) .. " && read -p ''")
    vim.defer_fn(function()
      local chan = vim.bo[vim.api.nvim_get_current_buf()].channel
      if chan and chan > 0 then
        vim.fn.chansend(chan, cmd .. "\n")
      end
    end, 200)
  end,
})

vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:block,r-cr-o:block"

-- how long the cursor must rest before CursorHold fires (drives auto-hover)
vim.opt.updatetime = 600

-- Flash a ✓ in the statusline right after format-on-save runs, so it's visible
-- that conform actually reformatted the buffer.
vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("ConformFlash", { clear = true }),
  callback = function(args)
    local ok, conform = pcall(require, "conform")
    if not ok then
      return
    end
    local lister = conform.list_formatters_to_run or conform.list_formatters
    local fmts = lister(args.buf)
    if not fmts or #fmts == 0 then
      return
    end
    vim.b[args.buf].conform_flash = true
    vim.cmd.redrawstatus()
    vim.defer_fn(function()
      if vim.api.nvim_buf_is_valid(args.buf) then
        vim.b[args.buf].conform_flash = nil
        vim.cmd.redrawstatus()
      end
    end, 1500)
  end,
})
