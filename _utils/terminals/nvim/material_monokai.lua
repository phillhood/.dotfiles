-- Material Monokai High Contrast theme for NvChad
-- Based on https://github.com/repeale/material-monokai

local M = {}

M.base_30 = {
  white = "#F8F8F2", -- default text
  darker_black = "#192227", -- panels, sidebars
  black = "#263238", -- nvim bg (editor)
  black2 = "#212c31",
  one_bg = "#2c3940",
  one_bg2 = "#323f47",
  one_bg3 = "#3a474f",
  grey = "#5F7A87", -- comments
  grey_fg = "#6a8594",
  grey_fg2 = "#7590a1",
  light_grey = "#8ca0ad",
  red = "#FF2C96", -- keywords, tags (magenta)
  baby_pink = "#ff6b9f",
  pink = "#FF2C96",
  line = "#2c3940",
  green = "#9DFF00", -- functions, accents (lime)
  vibrant_green = "#b5ff4d",
  nord_blue = "#82aaff", -- info
  blue = "#2EDCFF", -- support (cyan)
  seablue = "#2EDCFF",
  yellow = "#E6DB74", -- strings
  sun = "#f0e68c",
  purple = "#B78AFF", -- numbers, constants
  dark_purple = "#9966cc",
  teal = "#2EDCFF",
  orange = "#FD971F", -- parameters
  cyan = "#2EDCFF",
  statusline_bg = "#192227", -- darker panel color
  lightbg = "#2c3940",
  pmenu_bg = "#9DFF00", -- accent lime
  folder_bg = "#2EDCFF",
}

M.base_16 = {
  base00 = "#263238", -- background (editor)
  base01 = "#263238", -- lighter bg (editor)
  base02 = "#5f7a87", -- selection bg
  base03 = "#5F7A87", -- comments
  base04 = "#8ca0ad", -- dark fg
  base05 = "#F8F8F2", -- default fg
  base06 = "#ffffff", -- light fg
  base07 = "#ffffff", -- lightest fg
  base08 = "#F8F8F2", -- variables (off-white)
  base09 = "#B78AFF", -- integers, constants (purple)
  base0A = "#E6DB74", -- classes (yellow)
  base0B = "#E6DB74", -- strings (yellow)
  base0C = "#2EDCFF", -- support (cyan)
  base0D = "#9DFF00", -- functions (lime)
  base0E = "#FF2C96", -- keywords (magenta)
  base0F = "#FD971F", -- deprecated, parameters (orange)
}

M.type = "dark"

-- Tree-sitter and syntax highlight overrides to match VSCode Material Monokai
M.polish_hl = {
  -- Editor background
  Normal = { bg = "#263238", fg = "#F8F8F2" },
  Cursor = { bg = "#ffffff", fg = "#263238" },
  TermCursor = { bg = "#ffffff" },

  -- Panels, sidebars, floats (darker)
  NormalFloat = { bg = "#192227" },
  FloatBorder = { bg = "#192227", fg = "#5F7A87" },
  NvimTreeNormal = { bg = "#192227" },
  NvimTreeNormalNC = { bg = "#192227" },
  NvimTreeWinSeparator = { bg = "#192227", fg = "#192227" },
  NvimTreeCursorLine = { bg = "#263238" },
  TbLineBufOn = { bg = "#192227" },
  TbLineBufOff = { bg = "#192227" },
  TblineFill = { bg = "#192227" },
  St_NormalMode = { bg = "#9DFF00", fg = "#192227" },
  StatusLine = { bg = "#192227" },
  Pmenu = { bg = "#192227" },
  PmenuSel = { bg = "#263238" },

  -- Comments
  Comment = { fg = "#5F7A87" },
  ["@comment"] = { fg = "#5F7A87" },

  -- Strings
  String = { fg = "#E6DB74" },
  ["@string"] = { fg = "#E6DB74" },

  -- Numbers and constants
  Number = { fg = "#B78AFF" },
  Float = { fg = "#B78AFF" },
  Boolean = { fg = "#B78AFF" },
  Constant = { fg = "#B78AFF" },
  ["@number"] = { fg = "#B78AFF" },
  ["@boolean"] = { fg = "#B78AFF" },
  ["@constant"] = { fg = "#B78AFF" },
  ["@constant.builtin"] = { fg = "#B78AFF" },

  -- Keywords
  Keyword = { fg = "#FF2C96" },
  Statement = { fg = "#FF2C96" },
  Conditional = { fg = "#FF2C96" },
  Repeat = { fg = "#FF2C96" },
  Exception = { fg = "#FF2C96" },
  StorageClass = { fg = "#FF2C96" },
  ["@keyword"] = { fg = "#FF2C96" },
  ["@keyword.function"] = { fg = "#FF2C96" },
  ["@keyword.return"] = { fg = "#FF2C96" },
  ["@keyword.operator"] = { fg = "#FF2C96" },
  ["@conditional"] = { fg = "#FF2C96" },
  ["@repeat"] = { fg = "#FF2C96" },
  ["@exception"] = { fg = "#FF2C96" },

  -- Functions
  Function = { fg = "#9DFF00" },
  ["@function"] = { fg = "#9DFF00" },
  ["@function.call"] = { fg = "#9DFF00" },
  ["@method"] = { fg = "#9DFF00" },
  ["@method.call"] = { fg = "#9DFF00" },

  -- Function parameters (orange, italic)
  ["@parameter"] = { fg = "#FD971F", italic = true },
  ["@variable.parameter"] = { fg = "#FD971F", italic = true },

  -- Variables
  Identifier = { fg = "#F8F8F2" },
  ["@variable"] = { fg = "#F8F8F2" },
  ["@variable.builtin"] = { fg = "#FD971F" },

  -- Types (cyan)
  Type = { fg = "#2EDCFF", italic = true },
  ["@type"] = { fg = "#2EDCFF" },
  ["@type.builtin"] = { fg = "#2EDCFF", italic = true },
  ["@type.definition"] = { fg = "#9DFF00", underline = true },

  -- Classes (lime, underlined)
  ["@constructor"] = { fg = "#9DFF00" },
  ["@class"] = { fg = "#9DFF00", underline = true },

  -- Support/builtin functions (cyan)
  ["@function.builtin"] = { fg = "#2EDCFF" },

  -- Tags (HTML/JSX)
  Tag = { fg = "#FF2C96" },
  ["@tag"] = { fg = "#FF2C96" },
  ["@tag.delimiter"] = { fg = "#F8F8F2" },
  ["@tag.attribute"] = { fg = "#9DFF00" },

  -- Operators
  Operator = { fg = "#FF2C96" },
  ["@operator"] = { fg = "#FF2C96" },

  -- Punctuation
  ["@punctuation.bracket"] = { fg = "#F8F8F2" },
  ["@punctuation.delimiter"] = { fg = "#F8F8F2" },

  -- Properties
  ["@property"] = { fg = "#9DFF00" },
  ["@field"] = { fg = "#F8F8F2" },

  -- Namespace/module
  ["@namespace"] = { fg = "#2EDCFF" },
  ["@module"] = { fg = "#2EDCFF" },
}

M = require("base46").override_theme(M, "material_monokai")

return M
