-- ==========================================================================
-- BASIC SETTINGS & COPY/PASTE
-- ==========================================================================
vim.g.mapleader = " "

local function paste()
  return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
end

vim.g.clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ["+"] = paste,
    ["*"] = paste,
  },
}

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
