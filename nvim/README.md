# Neovim Professional Configuration for Arch Linux

## Overview
This repository provides a professional, modular Neovim configuration tailored for Arch Linux users. It includes a robust setup script, curated plugins for development, and detailed settings for productivity, code quality, and modern workflows.

---

## Setup Script: `scripts/neovim_setup.sh`

This script automates the installation of all required dependencies, language servers, and tools for a seamless Neovim experience on Arch Linux.

### Features
- **Banner and clear output** for a professional look
- **Idempotent**: Safe to run multiple times
- **Error handling** and clear next steps
- **Installs:**
  - System dependencies (via `paru`)
  - Vim-Plug plugin manager
  - LSP servers (via `npm`)
  - Rust toolchain and extras
  - Python tools (via `pipx`)

### Usage
```sh
bash scripts/neovim_setup.sh
```

---

## Directory Structure

- `init.lua` — Main Neovim entry point
- `lua/plugins.lua` — Plugin list (Vim-Plug)
- `lua/settings.lua` — Core Neovim settings and keymaps
- `lua/plugin-settings/` — Individual plugin configuration modules
- `scripts/neovim_setup.sh` — Automated setup script

---

## Plugin List and Purpose

Below is a summary of the main plugins, why they are included, and their configuration files:

| Plugin | Purpose | Config File |
|--------|---------|-------------|
| **nightfox.nvim, rose-pine/neovim** | Modern color schemes for aesthetics and readability | `colors.lua` |
| **nvim-lspconfig** | LSP support for code intelligence | `lsp.lua` |
| **nvim-cmp, cmp-nvim-lsp, cmp-buffer, cmp-path, LuaSnip, cmp_luasnip** | Autocompletion and snippets | `lsp.lua`, `copilot-cmp.lua` |
| **nvim-lint** | Asynchronous linting for multiple languages | `nvim-lint.lua` |
| **fzf-lua** | Fuzzy file and text search | `fzf-lua.lua` |
| **harpoon** | Quick file navigation/bookmarking | `harpoon.lua` |
| **nvim-treesitter** | Syntax highlighting and better indentation | `treesitter.lua`, `conform.lua` |
| **lualine.nvim** | Statusline customization | `lualine.lua` |
| **oil.nvim** | Modern file explorer | `oil.lua` |
| **gitsigns.nvim** | Git integration and inline signs | `gitsigns.lua` |
| **nvim-autopairs** | Auto-close brackets, quotes, etc. | `autopairs.lua` |
| **nvim-dap, nvim-dap-ui, nvim-dap-python** | Debugging support (DAP) | `debugger.lua` |
| **goerz/jupytext.vim, bfredl/nvim-ipy** | Jupyter and interactive Python support | `jupyter.lua` |
| **vim-dadbod, vim-dadbod-ui, vim-dadbod-completion** | SQL/Database client and UI | `sql.lua` |
| **vim-abolish, traces.vim** | Advanced regex and live preview | `regex.lua` |
| **which-key.nvim** | Keybinding discovery | `whichkey.lua` |
| **conform.nvim** | Autoformatting for multiple languages | `conform.lua` |
| **lazygit.nvim** | Git TUI integration | (see plugins.lua) |
| **nvim-colorizer.lua** | Color highlighting in code | `colorizer.lua` |
| **noice.nvim, nui.nvim, nvim-notify** | Enhanced UI for messages, command line, popups | `noice.lua` |
| **copilot.lua, copilot-cmp** | GitHub Copilot AI integration | `copilot.lua`, `copilot-cmp.lua` |

---

## Plugin Settings Modules

Each file in `lua/plugin-settings/` configures a specific plugin or feature. For example:
- `conform.lua`: Sets up autoformatting for Python, Lua, JS, etc.
- `nvim-lint.lua`: Configures linters for various languages.
- `lsp.lua`: LSP and completion setup.
- `fzf-lua.lua`: Fuzzy finder configuration and keymaps.
- `debugger.lua`: Debug Adapter Protocol (DAP) setup for Python, C++, etc.
- `oil.lua`: File explorer with custom keymaps.
- `colorizer.lua`: Color highlighting for CSS, Tailwind, etc.
- `sql.lua`: Database UI and completion.
- `jupyter.lua`: Jupyter/IPython integration.
- `whichkey.lua`: Keybinding helper.

---

## Core Settings (`lua/settings.lua`)
- Line numbers, relative numbers, and color support
- Indentation: 2 spaces, expandtab, smartindent
- Text wrapping, linebreak, and max line length
- Search: ignorecase, smartcase
- Performance: reduced update time, fast timeouts
- Split window behavior
- Persistent undo, no swap/backup files
- Keymaps for saving, quitting, splits, yanking to clipboard, and more

---

## How to Use
1. Run the setup script: `bash scripts/neovim_setup.sh`
2. Copy your config files to `~/.config/nvim/` if not already present
3. Open Neovim and run `:PlugInstall`
4. Enjoy a modern, professional Neovim experience!

---

## Customization
Feel free to edit or extend any module in `lua/plugin-settings/` to suit your workflow. Each file is self-contained and documented for easy modification.

---

## License
MIT 