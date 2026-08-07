-- Plugins, installed by vim.pack (built into Neovim 0.12).
--
-- vim.pack.add clones anything missing into the pack directory and adds it to
-- the runtimepath. There is no lockfile and no lazy-loading DSL: `:h vim.pack`
-- covers the whole API. Update everything with :lua vim.pack.update().
--
-- Adding a plugin means adding a line here plus its setup call below. Removing
-- one means deleting both, then :lua vim.pack.del({ "name" }) to take it off
-- disk.

vim.pack.add({
  -- Theme.
  { src = "https://github.com/folke/tokyonight.nvim" },

  -- Icons, used by oil, lualine, trouble and snacks.
  { src = "https://github.com/nvim-mini/mini.icons" },

  -- Pickers, file explorer, and the terminal that claudecode.nvim drives.
  { src = "https://github.com/folke/snacks.nvim" },

  -- Claude Code integration.
  { src = "https://github.com/coder/claudecode.nvim" },

  -- Syntax and indentation.
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },

  -- Server definitions only. This is never required or set up: it ships
  -- lsp/<server>.lua files that the built-in vim.lsp.enable reads. See lsp.lua.
  { src = "https://github.com/neovim/nvim-lspconfig" },

  -- Completion.
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },

  -- Editing and navigation.
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/kylechui/nvim-surround" },

  -- Git and diagnostics.
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/folke/trouble.nvim" },

  -- Statusline.
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
})

local map = vim.keymap.set

-- === Theme ===
require("tokyonight").setup({
  style = "night",
  terminal_colors = true,
  styles = {
    comments = { italic = true },
    keywords = { italic = true },
    sidebars = "dark",
    floats = "dark",
  },
})
vim.cmd.colorscheme("tokyonight-night")

-- === Icons ===
require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons() -- plugins that ask for nvim-web-devicons get these

-- === Snacks: picker, explorer, and supporting UI ===
require("snacks").setup({
  picker = { enabled = true },
  explorer = { enabled = true },
  bigfile = { enabled = true }, -- disable expensive features on huge files
  quickfile = { enabled = true },
  input = { enabled = true },
  notifier = { enabled = true },
})

map("n", "<leader><space>", function() Snacks.picker.smart() end, { desc = "Find files" })
map("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Find files" })
map("n", "<leader>fg", function() Snacks.picker.grep() end, { desc = "Grep" })
map("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "Buffers" })
map("n", "<leader>fh", function() Snacks.picker.help() end, { desc = "Help pages" })
map("n", "<leader>fr", function() Snacks.picker.recent() end, { desc = "Recent files" })
map("n", "<leader>fw", function() Snacks.picker.grep_word() end, { desc = "Grep word under cursor" })
map("n", "<leader>e", function() Snacks.explorer() end, { desc = "File tree" })

-- === Claude Code ===
require("claudecode").setup({
  terminal = {
    split_side = "right",
    split_width_percentage = 0.30,
  },
})

map("n", "<leader>ac", "<cmd>ClaudeCode<cr>", { desc = "Toggle Claude" })
map("n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", { desc = "Focus Claude" })
map("n", "<leader>ar", "<cmd>ClaudeCode --resume<cr>", { desc = "Resume Claude" })
map("n", "<leader>aC", "<cmd>ClaudeCode --continue<cr>", { desc = "Continue Claude" })
map("v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", { desc = "Send to Claude" })
map("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", { desc = "Add buffer to context" })
map("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Accept diff" })
map("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Deny diff" })

-- === Treesitter ===
-- The main branch installs parsers on demand and leaves highlighting to
-- vim.treesitter.start(), rather than wrapping it in a setup table.
--
-- Compiling parsers needs the tree-sitter CLI on PATH; it comes from the
-- Brewfile as tree-sitter-cli. Without it, install fails and there is no
-- highlighting. (The `tree-sitter` formula is the library, not the CLI.)
local parsers = {
  "bash", "css", "dockerfile", "go", "gomod", "gosum", "html", "javascript",
  "json", "lua", "markdown", "markdown_inline", "python", "toml", "tsx",
  "typescript", "vim", "vimdoc", "yaml",
}

-- Only install what is actually missing, so startup does not spawn a job every
-- time. Run :lua require("nvim-treesitter").update() to refresh them.
local have = {}
for _, path in ipairs(vim.api.nvim_get_runtime_file("parser/*.so", true)) do
  have[vim.fn.fnamemodify(path, ":t:r")] = true
end
local missing = vim.tbl_filter(function(p) return not have[p] end, parsers)
if #missing > 0 then require("nvim-treesitter").install(missing) end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true }),
  desc = "Start treesitter highlighting where a parser exists",
  callback = function(event)
    local lang = vim.treesitter.language.get_lang(event.match)
    if lang and pcall(vim.treesitter.start, event.buf, lang) then
      vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

-- === Completion ===
require("blink.cmp").setup({
  keymap = { preset = "default" }, -- Ctrl-y accepts, Ctrl-n/p cycle
  appearance = { nerd_font_variant = "mono" },
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 200 },
  },
  sources = { default = { "lsp", "path", "snippets", "buffer" } },
  fuzzy = { implementation = "prefer_rust_with_warning" },
})

-- === Editing ===
require("oil").setup({ view_options = { show_hidden = true } })
map("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })
map("n", "<leader>O", "<cmd>Oil<cr>", { desc = "Open folder in Oil" })

require("nvim-surround").setup()

-- === Git ===
require("gitsigns").setup({
  on_attach = function(bufnr)
    local gs = require("gitsigns")
    local function m(mode, lhs, rhs, desc)
      map(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end
    m("n", "]c", function() gs.nav_hunk("next") end, "Next hunk")
    m("n", "[c", function() gs.nav_hunk("prev") end, "Previous hunk")
    m("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
    m("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
    m("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
    m("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
  end,
})

-- === Diagnostics list ===
require("trouble").setup()
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics" })
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer diagnostics" })
map("n", "<leader>xl", "<cmd>Trouble loclist toggle<cr>", { desc = "Location list" })
map("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix list" })

-- === Statusline ===
require("lualine").setup({
  options = {
    theme = "tokyonight",
    section_separators = "",
    component_separators = "|",
    globalstatus = true,
  },
})
