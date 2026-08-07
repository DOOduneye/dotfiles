-- ~/.config/nvim/init.lua
--
-- No framework and no plugin manager dependency. Plugins are installed by
-- vim.pack, which ships with Neovim 0.12, and LSP is configured with the
-- built-in vim.lsp.config / vim.lsp.enable. Requires Neovim 0.12 or newer.

if vim.fn.has("nvim-0.12") == 0 then
  vim.notify("This config needs Neovim 0.12 or newer", vim.log.levels.ERROR)
  return
end

-- Leader has to be set before any plugin registers a mapping.
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- === Options ===
local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes" -- always present, so text does not jump when a sign appears
opt.cursorline = true
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.termguicolors = true

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true -- a capital letter in the pattern makes the search case-sensitive
opt.inccommand = "split" -- live preview of :substitute

opt.splitbelow = true
opt.splitright = true

opt.undofile = true -- undo history survives closing the file
opt.swapfile = false
opt.writebackup = false

opt.updatetime = 200 -- how long before CursorHold fires; drives LSP hover highlights
opt.timeoutlen = 400 -- how long to wait for a mapping to complete
opt.confirm = true -- ask instead of failing when quitting with unsaved changes
opt.mouse = "a"
opt.clipboard = "unnamedplus" -- share the system clipboard

-- === Keymaps ===
local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Write" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit" })

-- Window navigation, matching the tmux Ctrl+h/j/k/l bindings.
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Keep the cursor in place when joining, and centred when jumping by half pages.
map("n", "J", "mzJ`z", { desc = "Join lines, keep cursor" })
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- Move the selection up and down.
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep the yanked text when pasting over a selection.
map("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })

map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous buffer" })

-- === Autocommands ===
local group = vim.api.nvim_create_augroup("UserConfig", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  desc = "Briefly highlight yanked text",
  callback = function() vim.hl.on_yank() end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  desc = "Create missing parent directories on write",
  callback = function(event)
    if event.match:match("^%w%w+://") then return end
    vim.fn.mkdir(vim.fn.fnamemodify(vim.uv.fs_realpath(event.match) or event.match, ":p:h"), "p")
  end,
})

require("plugins")
require("lsp")
