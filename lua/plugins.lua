-- ==========================================================================
-- MODERN PLUGIN MANAGER (lazy.nvim)
-- ==========================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ==========================================================================
-- PLUGINS & CONFIGURATIONS
-- ==========================================================================
require("lazy").setup({

  -- Theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if not ok then return end
      configs.setup({
        ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "bash", "python" },
        auto_install = true,
        highlight = { enable = true },
      })
    end,
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({ options = { theme = "catppuccin" } })
    end,
  },

  -- File explorer
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("oil").setup({ view_options = { show_hidden = true } })
    end,
  },

  -- Terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 20,
        open_mapping = nil, -- don't create internal mapping (prevents empty-LHS crash)
        direction = "float",
        float_opts = { border = "curved" },
      })
    end,
  },

  -- Markdown: HTML rendered preview (browser)
  {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown" },
    cmd = { "MarkdownPreview", "MarkdownPreviewToggle", "MarkdownPreviewStop" },
    build = ":call mkdp#util#install()",
    init = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_open_to_the_world = 0
      vim.g.mkdp_open_ip = "127.0.0.1"
    end,
  },

  -- LaTeX
  {
    "lervag/vimtex",
    ft = { "tex", "plaintex" },
    init = function()
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_quickfix_mode = 0
    end,
  },

  -- Code runner
  {
    "CRAG666/code_runner.nvim",
    config = function()
      require("code_runner").setup({
        mode = "float",
        float = { close_key = "", border = "rounded" },
        filetype = {
          python = "python3 -u",
          javascript = "node",
          c = "cd $dir && gcc $fileName -o $fileNameWithoutExt && $dir/$fileNameWithoutExt",
          cpp = "cd $dir && g++ $fileName -o $fileNameWithoutExt && $dir/$fileNameWithoutExt",
          rust = "cd $dir && rustc $fileName && $dir/$fileNameWithoutExt",
          sh = "bash $fileName",
        },
      })
    end,
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },

  -- LazyGit
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  {
  "mrjones2014/smart-splits.nvim",
  event = "VeryLazy",
  opts = {
    -- we are NOT using tmux/wezterm/kitty/zellij integration
    multiplexer_integration = nil,
    default_amount = 3,
    at_edge = "wrap", -- or "stop" / "split"
  },
}

})

