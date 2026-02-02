return {
  -- Snacks.nvim (required for claudecode.nvim terminal)
  { "folke/snacks.nvim", lazy = false, priority = 1000, opts = {} },

  -- Oil.nvim - file explorer that edits filesystem like a buffer
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Oil",
    keys = {
      { "<leader>O", "<cmd>Oil<cr>", desc = "Open folder in Oil" },
    },
    opts = {},
  },

  -- Trouble.nvim - better diagnostics list
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Trouble Document Diagnostics" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Trouble Workspace Diagnostics" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Location List" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List" },
    },
    opts = {},
  },

  -- nvim-surround - add/change/delete surrounding pairs
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },

  -- Note: gitsigns is already included in AstroNvim by default
  -- Note: which-key is already included in AstroNvim by default
  -- Note: neoscroll removed - snacks.scroll can be enabled instead
}
