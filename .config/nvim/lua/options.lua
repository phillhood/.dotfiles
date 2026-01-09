require "nvchad.options"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!

-- Use Treesitter for indentation instead of legacy Vim indent files
vim.opt.indentexpr = "nvim_treesitter#indent()"

-- Diagnostic display settings (underline errors like VS Code)
vim.diagnostic.config({
  underline = true,
  virtual_text = false,
  signs = true,
  float = {
    border = "rounded",
    format = function(diagnostic)
      return diagnostic.message
    end,
  },
})

-- Show diagnostic float on hover
vim.o.updatetime = 300
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focus = false })
  end,
})
