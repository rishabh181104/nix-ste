vim.g.traces_abolish_integration = 1

vim.keymap.set("n", "<leader>re", ":substitute//g<Left><Left>", { desc = "Regex replace" })
