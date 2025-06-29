require("colorizer").setup({
  -- Apply the plugin to all filetypes
  filetypes = {
    "*", -- Enable for all filetypes
    -- Optionally exclude specific filetypes, e.g., "!vim", "!lua"
  },

  -- Default options to enable ALL supported color formats with dynamic updates
  user_default_options = {
    RGB = true, -- Enable #RGB hex codes (e.g., #FFF)
    RRGGBB = true, -- Enable #RRGGBB hex codes (e.g., #FFFFFF)
    RRGGBBAA = true, -- Enable #RRGGBBAA hex codes with alpha (e.g., #FFFFFF80)
    AARRGGBB = true, -- Enable #AARRGGBB codes (e.g., #80FFFFFF)
    rgb_fn = true, -- Enable CSS rgb() functions (e.g., rgb(255, 255, 255))
    rgba_fn = true, -- Enable CSS rgba() functions (e.g., rgba(255, 255, 255, 0.5))
    hsl_fn = true, -- Enable CSS hsl() functions (e.g., hsl(120, 100%, 50%))
    hsla_fn = true, -- Enable CSS hsla() functions (e.g., hsla(120, 100%, 50%, 0.5))
    css = true, -- Enable CSS-specific color formats (e.g., rgb(), hsl() in CSS context)
    css_fn = true, -- Enable CSS function-style colors (e.g., rgba(), hsla())
    names = true, -- Enable named colors (e.g., "red", "blue", "green")
    tailwind = true, -- Enable Tailwind CSS colors (e.g., "bg-blue-500")
    sass = { enable = true, parsers = { "css" } }, -- Enable SASS-specific parsing
    mode = "background", -- Display mode: 'background', 'foreground', or 'virtualtext'
    virtualtext = "■", -- Symbol for virtualtext mode (used if mode = "virtualtext")
    always_update = true, -- Always update highlights on buffer changes (dynamic updates)
  },

  -- Buffer-local options (optional, uncomment to restrict buffer types)
  -- buftypes = { "*", "!prompt", "!popup" }, -- Apply to specific buffer types
})

-- Keymap to toggle colorizer on/off for the current buffer
vim.keymap.set("n", "<leader>tc", "<cmd>ColorizerToggle<CR>", { desc = "Toggle Colorizer" })
