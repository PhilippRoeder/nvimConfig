-- ==========================================================================
-- BASIC SETTINGS & COPY/PASTE
-- ==========================================================================
vim.g.mapleader = " "

-- Detect if we are running over an SSH connection
local is_ssh = vim.env.SSH_CLIENT ~= nil or vim.env.SSH_TTY ~= nil

if is_ssh then
  -- Remote SSH: Use OSC 52 ONLY for copying. Disable pasting for security.
  vim.g.clipboard = {
    name = "OSC 52 (Copy Only)",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = function()
        vim.notify("Remote paste disabled for security. Use your terminal's paste (Ctrl+Shift+V / Cmd+V)", vim.log.levels.WARN)
        return { "", "v" }
      end,
      ["*"] = function()
        vim.notify("Remote paste disabled for security. Use your terminal's paste (Ctrl+Shift+V / Cmd+V)", vim.log.levels.WARN)
        return { "", "v" }
      end,
    },
  }
else
  -- Locally: Do nothing. Neovim will automatically use your native system 
  -- clipboard (pbcopy/xclip/wl-clipboard) for completely secure local copy/paste.
end

vim.opt.clipboard = "unnamedplus"

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true

vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

vim.opt.autochdir = true

-- Automatically change directory when opening Neovim with a folder argument
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local path = vim.fn.argv(0)
    if type(path) == "string" and path ~= "" and vim.fn.isdirectory(path) == 1 then
      vim.cmd("cd " .. vim.fn.fnameescape(path))
    end
  end,
})
