-- ==========================================================================
-- KEYMAPS (leader + arrows tiling, Oil explorer in direction)
-- ==========================================================================

-- Oil (current window)
vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Oil: open parent/current directory" })

-- LazyGit
vim.keymap.set("n", "<leader>g", "<cmd>LazyGit<cr>", { desc = "LazyGit" })

-- ==========================================================================
-- Helpers
-- ==========================================================================

local function tnorm()
  if vim.fn.mode() == "t" then
    local esc = vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true)
    vim.api.nvim_feedkeys(esc, "n", false)
  end
end

local function with_tnorm(fn)
  return function()
    tnorm()
    fn()
  end
end

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = (opts.silent ~= false)
  opts.noremap = (opts.noremap ~= false)
  vim.keymap.set(mode, lhs, rhs, opts)
end

local function current_dir()
  if vim.bo.filetype == "oil" then
    local ok, oil = pcall(require, "oil")
    if ok then
      local d = oil.get_current_dir()
      if d and d ~= "" then return d end
    end
  end

  local d = vim.fn.expand("%:p:h")
  if d and d ~= "" then return d end
  return vim.fn.getcwd()
end

local function split_dir(where)
  if where == "left" then
    vim.cmd("leftabove vsplit")
  elseif where == "right" then
    vim.cmd("rightbelow vsplit")
  elseif where == "up" then
    vim.cmd("leftabove split")
  elseif where == "down" then
    vim.cmd("rightbelow split")
  else
    return false
  end
  return true
end

local function open_oil_in_split(where)
  local dir = current_dir()
  if not split_dir(where) then return end
  vim.cmd({ cmd = "Oil", args = { dir } })
end

-- ==========================================================================
-- Tiling maps (apply globally + buffer-locally for Oil)
-- ==========================================================================

local function apply_tiling_maps(opts)
  opts = opts or {}

  -- Focus navigation: Space + arrows
  map({ "n", "t" }, "<leader><Left>",  with_tnorm(function() vim.cmd("wincmd h") end), vim.tbl_extend("force", opts, { desc = "Focus left pane" }))
  map({ "n", "t" }, "<leader><Down>",  with_tnorm(function() vim.cmd("wincmd j") end), vim.tbl_extend("force", opts, { desc = "Focus down pane" }))
  map({ "n", "t" }, "<leader><Up>",    with_tnorm(function() vim.cmd("wincmd k") end), vim.tbl_extend("force", opts, { desc = "Focus up pane" }))
  map({ "n", "t" }, "<leader><Right>", with_tnorm(function() vim.cmd("wincmd l") end), vim.tbl_extend("force", opts, { desc = "Focus right pane" }))

  -- Resize: Space w + arrows (no Shift; more reliable in Oil/term)
  map({ "n", "t" }, "<leader>w<Left>",  with_tnorm(function() vim.cmd("vertical resize -5") end), vim.tbl_extend("force", opts, { desc = "Resize narrower" }))
  map({ "n", "t" }, "<leader>w<Right>", with_tnorm(function() vim.cmd("vertical resize +5") end), vim.tbl_extend("force", opts, { desc = "Resize wider" }))
  map({ "n", "t" }, "<leader>w<Up>",    with_tnorm(function() vim.cmd("resize +2") end),          vim.tbl_extend("force", opts, { desc = "Resize taller" }))
  map({ "n", "t" }, "<leader>w<Down>",  with_tnorm(function() vim.cmd("resize -2") end),          vim.tbl_extend("force", opts, { desc = "Resize shorter" }))

  -- Window actions
  map("n", "<leader>=", "<cmd>wincmd =<cr>", vim.tbl_extend("force", opts, { desc = "Equalize panes" }))
  map("n", "<leader>o", "<cmd>only<cr>",     vim.tbl_extend("force", opts, { desc = "Only this pane (zoom)" }))
  map("n", "<leader>q", "<cmd>close<cr>",    vim.tbl_extend("force", opts, { desc = "Close pane" }))

  -- New empty file panes: Space n + arrows
  map("n", "<leader>n<Left>",  "<cmd>leftabove vnew<cr>",  vim.tbl_extend("force", opts, { desc = "New file pane left" }))
  map("n", "<leader>n<Right>", "<cmd>rightbelow vnew<cr>", vim.tbl_extend("force", opts, { desc = "New file pane right" }))
  map("n", "<leader>n<Up>",    "<cmd>leftabove new<cr>",   vim.tbl_extend("force", opts, { desc = "New file pane up" }))
  map("n", "<leader>n<Down>",  "<cmd>rightbelow new<cr>",  vim.tbl_extend("force", opts, { desc = "New file pane down" }))

  -- New tiled terminal panes: Space t + arrows
  map("n", "<leader>t<Left>",  "<cmd>leftabove vsplit | terminal<cr>",   vim.tbl_extend("force", opts, { desc = "Terminal pane left" }))
  map("n", "<leader>t<Right>", "<cmd>rightbelow vsplit | terminal<cr>",  vim.tbl_extend("force", opts, { desc = "Terminal pane right" }))
  map("n", "<leader>t<Up>",    "<cmd>leftabove split | terminal<cr>",    vim.tbl_extend("force", opts, { desc = "Terminal pane up" }))
  map("n", "<leader>t<Down>",  "<cmd>rightbelow split | terminal<cr>",   vim.tbl_extend("force", opts, { desc = "Terminal pane down" }))

  -- Explorer panes (Oil): Space e + arrows
  map("n", "<leader>e<Left>",  function() open_oil_in_split("left") end,  vim.tbl_extend("force", opts, { desc = "Explorer left (Oil)" }))
  map("n", "<leader>e<Right>", function() open_oil_in_split("right") end, vim.tbl_extend("force", opts, { desc = "Explorer right (Oil)" }))
  map("n", "<leader>e<Up>",    function() open_oil_in_split("up") end,    vim.tbl_extend("force", opts, { desc = "Explorer up (Oil)" }))
  map("n", "<leader>e<Down>",  function() open_oil_in_split("down") end,  vim.tbl_extend("force", opts, { desc = "Explorer down (Oil)" }))
end

-- Global maps
apply_tiling_maps()

-- Re-apply as buffer-local maps inside Oil buffers (so Oil can't override them)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "oil",
  callback = function(ev)
    apply_tiling_maps({ buffer = ev.buf })
  end,
})

-- ==========================================================================
-- ToggleTerm (float terminals by ID)
-- ==========================================================================

-- Global float terminal (id=1)
map({ "n", "t" }, "<F4>", "<cmd>1ToggleTerm direction=float<cr>", { desc = "ToggleTerm global float (id=1)" })

-- CWD float terminal (id=2): Space t t
map("n", "<leader>tt", function()
  local dir = current_dir()
  local Terminal = require("toggleterm.terminal").Terminal
  local term = Terminal:new({ id = 2, direction = "float" })
  term:toggle()
  if term:is_open() then
    term:send("cd " .. vim.fn.shellescape(dir) .. " && clear")
  end
end, { desc = "ToggleTerm cwd float (id=2)" })

-- Live server (float terminal id=4): Space l s
map("n", "<leader>ls", function()
  local dir = current_dir()

  local cmd
  if vim.fn.executable("live-server") == 1 then
    cmd = "live-server"
  elseif vim.fn.executable("npx") == 1 then
    cmd = "npx --yes live-server"
  elseif vim.fn.executable("python3") == 1 then
    cmd = "python3 -m http.server 8000"
  else
    vim.notify("Need live-server OR npx OR python3 in PATH", vim.log.levels.ERROR)
    return
  end

  local Terminal = require("toggleterm.terminal").Terminal
  Terminal:new({
    id = 4,
    direction = "float",
    cmd = cmd,
    dir = dir,
    close_on_exit = false,
  }):toggle()
end, { desc = "Live Server (id=4, float)" })

-- ==========================================================================
-- Markdown / LaTeX / Run
-- ==========================================================================

map("n", "<leader>r", "<cmd>RunCode<cr>", { desc = "Run Code" })
map("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", { desc = "Markdown Preview (HTML)" })

map("n", "<leader>lp", function()
  if vim.bo.filetype ~= "tex" and vim.bo.filetype ~= "plaintex" then
    vim.notify("Not a TeX buffer", vim.log.levels.WARN)
    return
  end
  vim.cmd("VimtexCompile")
  vim.cmd("VimtexView")
end, { desc = "LaTeX compile + view" })

