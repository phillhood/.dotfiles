require "nvchad.autocmds"

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      require("nvim-tree.api").tree.open()
    end
  end,
})
