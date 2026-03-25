-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Detect filetype for chezmoi .tmpl files based on the underlying extension
vim.filetype.add({
  pattern = {
    [".*%.tmpl"] = function(path)
      local name = vim.fn.fnamemodify(path:gsub("%.tmpl$", ""), ":t")
      -- Convert chezmoi naming conventions to real filenames
      name = name:gsub("^dot_", ".")
      name = name:gsub("^private_", "")
      name = name:gsub("^executable_", "")
      name = name:gsub("^readonly_", "")
      return vim.filetype.match({ filename = name })
    end,
  },
})

