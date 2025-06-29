require("oil").setup({
    default_file_explorer = true,
    columns = { "icon" },
    view_options = { show_hidden = true },
    keymaps = {
        -- Navigation
        ["<CR>"] = { "actions.select", mode = "n", desc = "Open file/directory" },
        ["h"] = { "actions.parent", mode = "n", desc = "Go to parent directory" },
        ["l"] = { "actions.select", mode = "n", desc = "Open file/directory" },
        ["-"] = { "actions.parent", mode = "n", desc = "Go to parent directory (alt)" },
        ["_"] = { "actions.open_cwd", mode = "n", desc = "Set cwd to current directory" },

        -- Splits and tabs
        ["<C-v>"] = { "actions.select", opts = { vertical = true }, mode = "n", desc = "Open in vertical split" },
        ["<C-x>"] = { "actions.select", opts = { horizontal = true }, mode = "n", desc = "Open in horizontal split" },
        ["<C-t>"] = { "actions.select", opts = { tab = true }, mode = "n", desc = "Open in new tab" },

        -- Actions
        ["<C-p>"] = { "actions.preview", mode = "n", desc = "Preview file" },
        ["<C-r>"] = { "actions.refresh", mode = "n", desc = "Refresh directory" },
        ["g."] = { "actions.toggle_hidden", mode = "n", desc = "Toggle hidden files" },
        ["gx"] = { "actions.open_external", mode = "n", desc = "Open in external program" },

        -- Buffer control
        ["q"] = { "actions.close", mode = "n", desc = "Close oil buffer" },
        ["<Esc>"] = {
            callback = function()
                if vim.fn.mode() == "n" then
                    require("oil.actions").close.callback()
                end
            end,
            mode = "n",
            desc = "Close oil buffer in normal mode",
        },

        -- Help and sorting
        ["g?"] = { "actions.show_help", mode = "n", desc = "Show help" },
        ["gs"] = { "actions.change_sort", mode = "n", desc = "Change sort order" },
    },
    use_default_keymaps = false, -- Disable unmapped defaults
})

-- Open oil with <leader>e
vim.keymap.set("n", "<leader>e", "<CMD>Oil<CR>", { desc = "Open oil file explorer" })
