vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        -- Set a mark (e.g., 'a') to save cursor position
        vim.cmd("normal! ma")
        -- Run conform.nvim formatting
        require("conform").format({ timeout_ms = 500 })
        -- Fallback to Neovim's built-in indenting
        vim.cmd("normal! gg=G")
        -- Restore cursor position using mark 'a'
        vim.cmd("normal! `a")
    end,
})
