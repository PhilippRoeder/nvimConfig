-- Ensure we are running a compatible version of Neovim
if vim.fn.has("nvim-0.10") == 0 then
    vim.notify("This config only supports Neovim 0.10+", vim.log.levels.ERROR)
    return
end

-- 1. Load core settings and options FIRST
-- It is important that mapleader is set before plugins load
require("options")

-- 2. Load the plugin manager and all tools
require("plugins")

-- 3. Load all custom keybindings
require("keymaps")
