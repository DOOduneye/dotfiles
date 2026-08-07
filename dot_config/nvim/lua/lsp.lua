-- LSP, using Neovim's built-in client configuration.
--
-- nvim-lspconfig is installed but never required or set up. Since v2 it ships
-- lsp/<server>.lua files describing how to launch each server, and Neovim's
-- built-in vim.lsp.enable reads those off the runtimepath. That replaces both
-- the lspconfig setup calls and Mason.
--
-- Server binaries come from Homebrew (see the Brewfile), not from Mason. If a
-- server does not start, check the binary is on PATH first — :checkhealth lsp
-- reports which ones attached.

vim.lsp.enable({
  "lua_ls",
  "ts_ls",
  "pyright",
  "tailwindcss",
  "jsonls",
  "yamlls",
  "dockerls",
  "marksman",
  "gopls",
})

-- Tell lua_ls about Neovim's runtime so editing this config does not produce a
-- wall of "undefined global vim" warnings.
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
})

-- === Diagnostics ===
vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = "●" },
  underline = true,
  severity_sort = true,
  float = { border = "rounded", source = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "E",
      [vim.diagnostic.severity.WARN] = "W",
      [vim.diagnostic.severity.INFO] = "I",
      [vim.diagnostic.severity.HINT] = "H",
    },
  },
})

-- === Keymaps, bound only where a server actually attached ===
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
  callback = function(event)
    local function map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = event.buf, desc = desc })
    end

    -- Neovim 0.11 already binds grn, gra, grr, gri and K by default; these are
    -- the additions and the picker-backed versions.
    map("gd", function() Snacks.picker.lsp_definitions() end, "Go to definition")
    map("gD", vim.lsp.buf.declaration, "Go to declaration")
    map("gy", function() Snacks.picker.lsp_type_definitions() end, "Go to type definition")
    map("gR", function() Snacks.picker.lsp_references() end, "References")
    map("<leader>ls", function() Snacks.picker.lsp_symbols() end, "Document symbols")
    map("<leader>ld", vim.diagnostic.open_float, "Line diagnostics")
    map("<leader>lr", vim.lsp.buf.rename, "Rename")
    map("<leader>la", vim.lsp.buf.code_action, "Code action")
    map("<leader>lf", function() vim.lsp.buf.format({ async = true }) end, "Format")

    -- Highlight other references to the symbol under the cursor.
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method("textDocument/documentHighlight") then
      local hl = vim.api.nvim_create_augroup("UserLspHighlight", { clear = false })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = event.buf,
        group = hl,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = event.buf,
        group = hl,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end,
})
