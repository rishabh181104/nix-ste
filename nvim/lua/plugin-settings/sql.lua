vim.g.db_ui_save_location = "~/.config/nvim/db_ui"

vim.keymap.set("n", "<leader>db", ":DBUIToggle<CR>", { desc = "Toggle DB UI" })

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "sql", "mysql", "plsql" },
    callback = function()
        require("cmp").setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
    end,
})
