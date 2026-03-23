return {
  -- 1. Inline Rendering (The "Visual" feel)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      heading = {
        sign = false,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      },
      code = {
        sign = false,
        width = "block",
        right_pad = 1,
      },
      checkbox = {
        enabled = true,
      },
    },
    ft = { "markdown" },
  },

  -- 2. Zen Mode (The "Reader" feel)
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = {
      window = {
        width = 120, -- width of the Zen window
        options = {
          number = false,         -- disable line numbers
          relativenumber = false, -- disable relative numbers
          cursorline = false,     -- disable cursorline
          signcolumn = "no",      -- disable signcolumn
        },
      },
      plugins = {
        gitsigns = { enabled = false }, -- hide git signs
        tmux = { enabled = true },      -- will help hide tmux status bar if you use it
      },
    },
    keys = {
      { "<leader>zz", "<cmd>ZenMode<cr>", desc = "Toggle Zen Mode" },
    },
  },
}
