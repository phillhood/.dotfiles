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
  dark_purple = "#B267E6", -- bracket color 1 (violet)
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
  base0A = "#9DFF00", -- classes (lime green, matching VS Code)
  base0B = "#E6DB74", -- strings (yellow)
  base0C = "#2EDCFF", -- support (cyan)
  base0D = "#9DFF00", -- functions (lime)
  base0E = "#FF2C96", -- keywords (magenta)
  base0F = "#FD971F", -- deprecated, parameters (orange)
}

M.type = "dark"

-- polish_hl must be organized by integration (defaults, treesitter, lsp, etc.)
M.polish_hl = {
  -- General Vim highlight groups
  defaults = {
    Normal = { bg = "#263238", fg = "#F8F8F2" },
    Cursor = { bg = "#ffffff", fg = "#263238" },
    TermCursor = { bg = "#ffffff" },
    NormalFloat = { bg = "#192227" },
    FloatBorder = { bg = "#192227", fg = "#5F7A87" },
    Pmenu = { bg = "#192227" },
    PmenuSel = { bg = "#263238" },
    Comment = { fg = "#5F7A87" },
    String = { fg = "#E6DB74" },
    Character = { fg = "#B78AFF" },  -- constant.character in VS Code
    Number = { fg = "#B78AFF" },
    Float = { fg = "#B78AFF" },
    Boolean = { fg = "#B78AFF" },
    Constant = { fg = "#B78AFF" },
    Keyword = { fg = "#FF2C96" },
    Statement = { fg = "#FF2C96" },
    Conditional = { fg = "#FF2C96" },
    Repeat = { fg = "#FF2C96" },
    Exception = { fg = "#FF2C96" },
    StorageClass = { fg = "#FF2C96" },
    Include = { fg = "#FF2C96" },
    Function = { fg = "#9DFF00" },
    Identifier = { fg = "#F8F8F2" },
    Type = { fg = "#9DFF00", underline = true },  -- types green+underline like VS Code
    Tag = { fg = "#FF2C96" },
    Operator = { fg = "#F8F8F2" },  -- VS Code has no explicit operator color
    Delimiter = { fg = "#c0c0c0" },
    -- Invalid
    Error = { fg = "#F8F8F0" },
    DiffAdd = { fg = "#9DFF00" },
    DiffDelete = { fg = "#FF2C96" },
    DiffChange = { fg = "#E6DB74" },
    DiagnosticInfo = { fg = "#6796E6" },
    DiagnosticHint = { fg = "#B267E6" },
    DiagnosticWarn = { fg = "#CD9731" },
    DiagnosticError = { fg = "#F44747" },

    -- LSP semantic tokens (must be in defaults, not separate section)
    ["@lsp.type.namespace"] = { fg = "#2EDCFF" },
    ["@lsp.type.type"] = { fg = "#9DFF00", underline = true },
    ["@lsp.type.class"] = { fg = "#9DFF00", underline = true },
    ["@lsp.type.enum"] = { fg = "#9DFF00", underline = true },
    ["@lsp.type.interface"] = { fg = "#9DFF00", underline = true },
    ["@lsp.type.struct"] = { fg = "#9DFF00", underline = true },
    ["@lsp.type.typeParameter"] = { fg = "#2EDCFF", italic = true },
    ["@lsp.type.parameter"] = { fg = "#FD971F", italic = true },
    ["@lsp.type.variable"] = { fg = "#F8F8F2" },
    ["@lsp.type.property"] = { fg = "#F8F8F2" },
    ["@lsp.type.enumMember"] = { fg = "#B78AFF" },
    ["@lsp.type.function"] = { fg = "#9DFF00" },
    ["@lsp.type.method"] = { fg = "#9DFF00" },
    ["@lsp.type.macro"] = { fg = "#2EDCFF" },
    ["@lsp.type.keyword"] = { fg = "#FF2C96" },
    ["@lsp.type.comment"] = { fg = "#5F7A87" },
    ["@lsp.type.string"] = { fg = "#E6DB74" },
    ["@lsp.type.number"] = { fg = "#B78AFF" },
    ["@lsp.type.regexp"] = { fg = "#E6DB74" },
    ["@lsp.type.operator"] = { fg = "#F8F8F2" },
    ["@lsp.type.decorator"] = { fg = "#9DFF00" },
    ["@lsp.mod.declaration"] = {},
    ["@lsp.mod.definition"] = {},
    ["@lsp.mod.readonly"] = {},
    ["@lsp.mod.defaultLibrary"] = { fg = "#2EDCFF" },
    ["@lsp.typemod.function.defaultLibrary"] = { fg = "#2EDCFF" },
    ["@lsp.typemod.variable.defaultLibrary"] = { fg = "#2EDCFF" },
    ["@lsp.typemod.class.defaultLibrary"] = { fg = "#9DFF00", underline = true },  -- built-in classes (Date, Map, etc.) still green
    ["@lsp.typemod.variable.readonly"] = { fg = "#F8F8F2" },  -- const vars are still white like regular vars
    ["@lsp.typemod.property.defaultLibrary"] = { fg = "#F8F8F2" },  -- built-in properties still white
    ["@lsp.typemod.property.readonly"] = { fg = "#F8F8F2" },  -- readonly properties still white
  },

  -- Treesitter highlight groups
  treesitter = {
    -- Comments
    ["@comment"] = { fg = "#5F7A87" },

    -- Strings
    ["@string"] = { fg = "#E6DB74" },
    ["@string.escape"] = { fg = "#B78AFF" },
    ["@string.special"] = { fg = "#B78AFF" },
    ["@string.regex"] = { fg = "#E6DB74" },
    ["@string.special.symbol"] = { fg = "#B78AFF" },
    ["@character"] = { fg = "#B78AFF" },  -- constant.character in VS Code
    ["@character.special"] = { fg = "#B78AFF" },

    -- Numbers and constants
    ["@number"] = { fg = "#B78AFF" },
    ["@boolean"] = { fg = "#B78AFF" },
    ["@constant"] = { fg = "#B78AFF" },
    ["@constant.builtin"] = { fg = "#2EDCFF" },

    -- Keywords
    ["@keyword"] = { fg = "#FF2C96" },
    ["@keyword.function"] = { fg = "#FF2C96" },
    ["@keyword.return"] = { fg = "#FF2C96" },
    ["@keyword.operator"] = { fg = "#FF2C96" },
    ["@keyword.import"] = { fg = "#FF2C96" },
    ["@keyword.export"] = { fg = "#FF2C96" },
    ["@keyword.directive"] = { fg = "#FF2C96" },
    ["@keyword.conditional"] = { fg = "#FF2C96" },
    ["@keyword.repeat"] = { fg = "#FF2C96" },
    ["@keyword.exception"] = { fg = "#FF2C96" },
    ["@keyword.storage"] = { fg = "#FF2C96" },
    ["@keyword.coroutine"] = { fg = "#FF2C96" },
    ["@keyword.type"] = { fg = "#2EDCFF", italic = true },  -- class, interface, type, enum
    ["@keyword.modifier"] = { fg = "#FF2C96" },  -- public, private, readonly, etc.
    ["@conditional"] = { fg = "#FF2C96" },
    ["@repeat"] = { fg = "#FF2C96" },
    ["@exception"] = { fg = "#FF2C96" },
    ["@include"] = { fg = "#FF2C96" },
    ["@storageclass"] = { fg = "#FF2C96" },

    -- Functions (don't define @function.method - let it inherit from @function)
    ["@function"] = { fg = "#9DFF00" },
    ["@function.call"] = { fg = "#9DFF00" },
    ["@function.builtin"] = { fg = "#2EDCFF" },

    -- Parameters
    ["@parameter"] = { fg = "#FD971F", italic = true },
    ["@variable.parameter"] = { fg = "#FD971F", italic = true },

    -- Variables
    ["@variable"] = { fg = "#F8F8F2" },
    ["@variable.builtin"] = { fg = "#FD971F" },
    ["@variable.member"] = { fg = "#F8F8F2" },

    -- Types
    ["@type"] = { fg = "#9DFF00", underline = true },  -- all type refs green+underline like VS Code
    ["@type.builtin"] = { fg = "#2EDCFF", italic = true },  -- built-in types (string, number) stay cyan
    ["@type.definition"] = { fg = "#9DFF00", underline = true },
    ["@type.qualifier"] = { fg = "#FF2C96" },

    -- Classes
    ["@constructor"] = { fg = "#2EDCFF" },  -- constructor keyword is cyan
    ["@constructor.typescript"] = { fg = "#2EDCFF" },
    ["@class"] = { fg = "#9DFF00", underline = true },

    -- Tags (HTML/JSX)
    ["@tag"] = { fg = "#FF2C96" },
    ["@tag.delimiter"] = { fg = "#F8F8F2" },
    ["@tag.attribute"] = { fg = "#9DFF00" },

    -- Operators and punctuation
    ["@operator"] = { fg = "#F8F8F2" },  -- VS Code has no explicit operator color
    ["@punctuation"] = { fg = "#c0c0c0" },
    ["@punctuation.bracket"] = { fg = "#c0c0c0" },
    ["@punctuation.delimiter"] = { fg = "#c0c0c0" },
    ["@punctuation.special"] = { fg = "#FF2C96" },  -- template ${} only

    -- Properties and fields (VS Code uses default text color)
    ["@property"] = { fg = "#F8F8F2" },
    ["@field"] = { fg = "#F8F8F2" },

    -- Namespace/module
    ["@namespace"] = { fg = "#2EDCFF" },
    ["@module"] = { fg = "#2EDCFF" },

    -- Decorators / Attributes (@ symbol should be white, name should be green)
    ["@attribute"] = { fg = "#9DFF00" },
    ["@attribute.builtin"] = { fg = "#9DFF00" },
    ["@punctuation.special.typescript"] = { fg = "#FF2C96" },  -- template ${}
    ["@punctuation.special.tsx"] = { fg = "#FF2C96" },

    -- TypeScript/JavaScript specific
    ["@keyword.import.typescript"] = { fg = "#FF2C96" },
    ["@keyword.import.tsx"] = { fg = "#FF2C96" },
    ["@keyword.import.javascript"] = { fg = "#FF2C96" },
    ["@include.typescript"] = { fg = "#FF2C96" },
    ["@include.tsx"] = { fg = "#FF2C96" },

    -- JSON
    ["@label.json"] = { fg = "#CFCFC2" },
    ["@property.json"] = { fg = "#CFCFC2" },

    -- Markup / Markdown
    ["@markup.heading"] = { fg = "#9DFF00" },
    ["@markup.heading.1"] = { fg = "#9DFF00", bold = true },
    ["@markup.heading.2"] = { fg = "#9DFF00", bold = true },
    ["@markup.heading.3"] = { fg = "#9DFF00" },
    ["@markup.heading.4"] = { fg = "#9DFF00" },
    ["@markup.heading.5"] = { fg = "#9DFF00" },
    ["@markup.heading.6"] = { fg = "#9DFF00" },
    ["@markup.quote"] = { fg = "#FF2C96" },
    ["@markup.list"] = { fg = "#E6DB74" },
    ["@markup.list.checked"] = { fg = "#9DFF00" },
    ["@markup.list.unchecked"] = { fg = "#E6DB74" },
    ["@markup.strong"] = { fg = "#2EDCFF", bold = true },
    ["@markup.italic"] = { fg = "#2EDCFF", italic = true },
    ["@markup.raw"] = { fg = "#FD971F" },
    ["@markup.raw.block"] = { fg = "#FD971F" },
    ["@markup.link"] = { fg = "#2EDCFF" },
    ["@markup.link.url"] = { fg = "#2EDCFF", underline = true },
    ["@markup.link.label"] = { fg = "#E6DB74" },

    -- Diff
    ["@diff.plus"] = { fg = "#9DFF00" },
    ["@diff.minus"] = { fg = "#FF2C96" },
    ["@diff.delta"] = { fg = "#E6DB74" },
  },

  -- NvimTree
  nvimtree = {
    NvimTreeNormal = { bg = "#192227" },
    NvimTreeNormalNC = { bg = "#192227" },
    NvimTreeWinSeparator = { bg = "#192227", fg = "#192227" },
    NvimTreeCursorLine = { bg = "#263238" },
  },

  -- Bufferline / Tabufline
  tbline = {
    TbLineBufOn = { bg = "#192227" },
    TbLineBufOff = { bg = "#192227" },
    TblineFill = { bg = "#192227" },
  },

  -- Statusline
  statusline = {
    St_NormalMode = { bg = "#9DFF00", fg = "#192227" },
    StatusLine = { bg = "#192227" },
  },
}

return M
