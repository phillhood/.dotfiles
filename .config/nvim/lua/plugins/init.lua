return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim", "lua", "vimdoc",
        "html", "css", "javascript", "typescript", "tsx",
        "json", "yaml", "markdown", "bash",
        "python", "go", "rust",
      },
    },
  },

  -- Supermaven AI autocomplete
  {
    "supermaven-inc/supermaven-nvim",
    event = "InsertEnter",
    config = function()
      require("supermaven-nvim").setup({
        keymaps = {
          accept_suggestion = "<Tab>",
          clear_suggestion = "<C-]>",
          accept_word = "<C-j>",
        },
        color = {
          suggestion_color = "#5F7A87",  -- match comment color
        },
      })
    end,
  },

  -- Rainbow indent lines
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "BufReadPost",
    main = "ibl",
    config = function()
      local hooks = require("ibl.hooks")
      -- Define rainbow colors using theme palette
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        -- Grey for first level, then muted rainbow colors
        vim.api.nvim_set_hl(0, "IndentGrey", { fg = "#3a474f" })
        vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#6b5280" })
        vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#8a8256" })
        vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#8a5a1a" })
        vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#2a7a8a" })
        vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#5a8a1a" })
        vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#8a2a5a" })
      end)
      require("ibl").setup({
        indent = {
          highlight = {
            "IndentGrey",
            "RainbowViolet",
            "RainbowYellow",
            "RainbowOrange",
            "RainbowCyan",
            "RainbowGreen",
            "RainbowRed",
          },
          char = "│",
        },
        scope = {
          enabled = true,
          show_start = false,
          show_end = false,
        },
      })
    end,
  },
}
