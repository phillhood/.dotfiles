local servers = {
  "html",
  "cssls",
  "ts_ls",       -- TypeScript/JavaScript
  "pyright",     -- Python
  "gopls",       -- Go
  "rust_analyzer", -- Rust
}
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers 
