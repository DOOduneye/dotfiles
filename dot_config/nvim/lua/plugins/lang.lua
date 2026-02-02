-- Language support is handled by Mason + LSP
-- AstroNvim auto-installs LSPs when you open files of that type
-- You can also manually install via :Mason

return {
  -- Ensure these LSPs/formatters/linters are installed
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "lua_ls",        -- Lua
        "ts_ls",         -- TypeScript/JavaScript
        "pyright",       -- Python
        "tailwindcss",   -- Tailwind CSS
        "jsonls",        -- JSON
        "yamlls",        -- YAML
        "dockerls",      -- Dockerfile
        "marksman",      -- Markdown
        "gopls",         -- Go
      },
    },
  },

  -- Additional treesitter parsers
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "lua",
        "typescript",
        "tsx",
        "javascript",
        "python",
        "json",
        "yaml",
        "dockerfile",
        "markdown",
        "markdown_inline",
        "css",
        "html",
        "bash",
        "go",
        "gomod",
        "gosum",
      },
    },
  },
}
