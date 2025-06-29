-- ============================================================================
-- Neovim Main Initialization File
-- Professional, Modular, and Readable Configuration
-- ============================================================================

-- Set <Space> as the leader key
vim.g.mapleader = " "

-- --------------------------------------------------------------------------
-- Load General Settings
-- --------------------------------------------------------------------------
require("settings")

-- --------------------------------------------------------------------------
-- Load Plugins (Vim-Plug)
-- --------------------------------------------------------------------------
require("plugins")

-- --------------------------------------------------------------------------
-- Load Plugin Settings (modular, each file configures a plugin)
-- --------------------------------------------------------------------------
local plugin_settings = {
  "autoindent",    -- Auto indentation on save
  "autopairs",     -- Auto-close brackets, quotes, etc.
  "colorizer",     -- Color highlighting in code
  "colors",        -- Theme and color palette
  "conform",       -- Autoformatting
  "copilot-cmp",   -- Copilot completion integration
  "copilot",       -- Copilot core
  "debugger",      -- Debug Adapter Protocol (DAP)
  "fzf-lua",       -- Fuzzy finder
  "gitsigns",      -- Git integration
  "harpoon",       -- Quick file navigation
  "jupyter",       -- Jupyter/IPython integration
  "lsp",           -- LSP and completion
  "lualine",       -- Statusline
  "noice",         -- Enhanced UI
  "nvim-lint",     -- Linting
  "oil",           -- File explorer
  "regex",         -- Regex helpers
  "sql",           -- SQL/Database UI
  "treesitter",    -- Syntax highlighting/indentation
  "whichkey",      -- Keybinding helper
}

-- Filetype autocmd for bspwmrc/sxhkdrc (shell syntax)
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "bspwmrc", "sxhkdrc" },
  command = "set filetype=sh",
})

-- Load each plugin setting module safely
for _, module in ipairs(plugin_settings) do
  local ok, err = pcall(require, "plugin-settings." .. module)
  if not ok then
    vim.notify("Error loading plugin-settings/" .. module .. ": " .. err, vim.log.levels.ERROR)
  end
end
