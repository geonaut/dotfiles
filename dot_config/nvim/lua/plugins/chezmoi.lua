return {
  "xvzc/chezmoi.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("chezmoi").setup({
      -- This plugin automatically handles the filetype detection
      -- and allows you to :ChezmoiApply directly from Neovim
    })

    -- Optional: Auto-apply on save
    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      pattern = { os.getenv("HOME") .. "/.local/share/chezmoi/*" },
      callback = function()
        require("chezmoi.commands").apply_without_confirm()
      end,
    })
  end,
}
