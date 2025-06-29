-- ============================================================================
-- conform.lua
-- Autoformatting Configuration (conform.nvim & nvim-treesitter)
-- Professional, Readable, and Well-Documented
-- ============================================================================

-- --------------------------------------------------------------------------
-- Setup conform.nvim for Autoformatting
-- --------------------------------------------------------------------------
require("conform").setup({
  formatters_by_ft = {
    python = { "black" },         -- Python: Black
    lua = { "stylua" },           -- Lua: Stylua
    javascript = { "prettier" },  -- JS: Prettier
    html = { "prettier" },        -- HTML: Prettier
    css = { "prettier" },         -- CSS: Prettier
    java = { "astyle" },          -- Java: AStyle
    cpp = { "clang-format" },     -- C++: Clang-Format
    rust = { "rustfmt" },         -- Rust: rustfmt
    sh = { "shfmt" },             -- Shell: shfmt
    -- go = { "gofmt" },          -- Go: gofmt (uncomment if needed)
  },
  format_on_save = {
    timeout_ms = 500,             -- Timeout for formatting on save
    lsp_fallback = true,          -- Use LSP formatting if formatter fails
  },
  formatters = {
    black = {
      prepend_args = { "--fast" }, -- Speed up Black
    },
    prettier = {
      prepend_args = { "--single-quote", "--trailing-comma", "es5" },
    },
    ["astyle"] = {
      command = "astyle",         -- Use astyle (adjust if using JAR)
    },
  },
})

-- --------------------------------------------------------------------------
-- Keymap: Manually Trigger Formatting
-- --------------------------------------------------------------------------
vim.api.nvim_set_keymap(
  "n",
  "<leader>for",
  "<cmd>lua require('conform').format({ async = true, lsp_fallback = true })<CR>",
  { noremap = true, silent = true }
)

-- --------------------------------------------------------------------------
-- Setup nvim-treesitter for Autoindenting & Highlighting
-- --------------------------------------------------------------------------
require("nvim-treesitter.configs").setup({
  ensure_installed = { "python", "lua", "javascript", "html", "css", "java", "cpp", "rust" },
  indent = {
    enable = true,
    disable = { "python" }, -- Rely on Black for Python indentation
  },
  highlight = { enable = true }, -- Enable syntax highlighting
})
