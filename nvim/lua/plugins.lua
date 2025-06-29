-- ============================================================================
-- plugins.lua
-- Plugin List for Neovim (Vim-Plug Syntax)
-- Professional, Readable, and Well-Documented
-- ============================================================================

vim.cmd([[
  call plug#begin('~/.local/share/nvim/plugged')

  " -------------------------------------------------------------------------
  " Theme Plugins
  " -------------------------------------------------------------------------
  Plug 'EdenEast/nightfox.nvim'         " Nightfox Theme
  Plug 'rose-pine/neovim'               " Rose-Pine Theme

  " -------------------------------------------------------------------------
  " LSP and Completion
  " -------------------------------------------------------------------------
  Plug 'neovim/nvim-lspconfig'          " LSP support
  Plug 'hrsh7th/nvim-cmp'               " Autocompletion
  Plug 'hrsh7th/cmp-nvim-lsp'           " LSP source for nvim-cmp
  Plug 'hrsh7th/cmp-buffer'             " Buffer source for nvim-cmp
  Plug 'hrsh7th/cmp-path'               " Path source for nvim-cmp
  Plug 'L3MON4D3/LuaSnip'               " Snippet engine
  Plug 'saadparwaiz1/cmp_luasnip'       " LuaSnip completion source

  " -------------------------------------------------------------------------
  " Linting
  " -------------------------------------------------------------------------
  Plug 'mfussenegger/nvim-lint'         " Asynchronous linting

  " -------------------------------------------------------------------------
  " Fuzzy Finder
  " -------------------------------------------------------------------------
  Plug 'ibhagwan/fzf-lua', { 'branch': 'main' } " Fuzzy finder

  " -------------------------------------------------------------------------
  " File Navigation
  " -------------------------------------------------------------------------
  Plug 'ThePrimeagen/harpoon', { 'branch': 'harpoon2' } " Quick file navigation
  Plug 'nvim-lua/plenary.nvim'          " Lua functions used by many plugins

  " -------------------------------------------------------------------------
  " Syntax Highlighting
  " -------------------------------------------------------------------------
  Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' } " Treesitter

  " -------------------------------------------------------------------------
  " Statusline
  " -------------------------------------------------------------------------
  Plug 'nvim-lualine/lualine.nvim'      " Statusline

  " -------------------------------------------------------------------------
  " File Explorer
  " -------------------------------------------------------------------------
  Plug 'stevearc/oil.nvim'              " Modern file explorer

  " -------------------------------------------------------------------------
  " Git Integration
  " -------------------------------------------------------------------------
  Plug 'lewis6991/gitsigns.nvim'        " Git signs in gutter

  " -------------------------------------------------------------------------
  " Auto-pairs
  " -------------------------------------------------------------------------
  Plug 'windwp/nvim-autopairs'          " Auto-close pairs

  " -------------------------------------------------------------------------
  " Debugging (DAP)
  " -------------------------------------------------------------------------
  Plug 'mfussenegger/nvim-dap'          " Debug Adapter Protocol
  Plug 'rcarriga/nvim-dap-ui'           " DAP UI
  Plug 'nvim-neotest/nvim-nio'          " Async IO for DAP
  Plug 'mfussenegger/nvim-dap-python'   " Python DAP
  Plug 'leoluz/nvim-dap-go'             " Go DAP (for reference)

  " -------------------------------------------------------------------------
  " Data Science (Jupyter, Python)
  " -------------------------------------------------------------------------
  Plug 'goerz/jupytext.vim'             " Jupyter notebook support
  Plug 'bfredl/nvim-ipy'                " Interactive Python

  " -------------------------------------------------------------------------
  " SQL/PostgreSQL
  " -------------------------------------------------------------------------
  Plug 'tpope/vim-dadbod'               " Database client
  Plug 'kristijanhusak/vim-dadbod-ui'   " Database UI
  Plug 'kristijanhusak/vim-dadbod-completion' " SQL completion

  " -------------------------------------------------------------------------
  " Regex Testing (Cybersecurity)
  " -------------------------------------------------------------------------
  Plug 'tpope/vim-abolish'              " Advanced regex tools
  Plug 'markonm/traces.vim'             " Live regex preview

  " -------------------------------------------------------------------------
  " Keybinding Helper
  " -------------------------------------------------------------------------
  Plug 'folke/which-key.nvim'           " Keybinding discovery

  " -------------------------------------------------------------------------
  " Auto Indenting/Formatting
  " -------------------------------------------------------------------------
  Plug 'stevearc/conform.nvim'          " Autoformatting
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

  " -------------------------------------------------------------------------
  " Lazygit Integration
  " -------------------------------------------------------------------------
  Plug 'kdheepak/lazygit.nvim'          " Lazygit in Neovim

  " -------------------------------------------------------------------------
  " Color Highlighting
  " -------------------------------------------------------------------------
  Plug 'catgoose/nvim-colorizer.lua'    " Color highlighting in code

  " -------------------------------------------------------------------------
  " Enhanced UI (Messages, CMDline, Popupmenu)
  " -------------------------------------------------------------------------
  Plug 'folke/noice.nvim'               " Enhanced UI
  Plug 'MunifTanjim/nui.nvim'           " UI components
  Plug 'rcarriga/nvim-notify'           " Notification UI

  " -------------------------------------------------------------------------
  " AI Integration
  " -------------------------------------------------------------------------
  Plug 'zbirenbaum/copilot.lua'         " GitHub Copilot
  Plug 'zbirenbaum/copilot-cmp'         " Copilot completion source

  call plug#end()
]])
