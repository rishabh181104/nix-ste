local fzf = require("fzf-lua")

fzf.setup({
    winopts = {
        height = 0.9,
        width = 0.9,
        preview = {
            hidden = "hidden",
        },
    },
    keymap = {
        fzf = {
            ["tab"] = "down", -- Rebind <Tab> to cycle down instead of toggling preview
            ["shift-tab"] = "up", -- Rebind <Shift-Tab> to cycle up
            ["ctrl-p"] = "toggle-preview", -- Use a different key to toggle the preview
        },
    },
})

-- Keymaps
vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "Search text" })
vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "Find buffers" })
