return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    -- The "Nice" window settings
    window = {
      width = 30,
      position = "left",
      mappings = {
        ["H"] = "toggle_hidden",
      },
    },
    -- The logic for your home folder
    filesystem = {
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = false,
      },
      follow_current_file = { enabled = true },
      -- THIS is the magic line to stop the basic tree from appearing
      hijack_netrw_behavior = "open_default",
    },
    -- Visuals (Top level!)
    renderers = {
      file = {
        { "indent" },
        { "icon" },
        { "name", use_git_status_colors = true },
      },
    },
  },
}