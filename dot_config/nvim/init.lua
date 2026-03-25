-- bootstrap lazy.nvim, LazyVim and your plugins
-- Add these to the TOP of init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("config.lazy")

function MyHomeLayout()
  -- 1. Open the sidebar (using built-in Netrw)
  vim.cmd('Lexplore')
  vim.g.netrw_winsize = 20

  -- 2. Move to the main window
  vim.cmd('wincmd l')
end
