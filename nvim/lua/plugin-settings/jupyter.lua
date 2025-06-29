vim.g.jupytext_fmt = "py:percent"

vim.keymap.set("n", "<leader>ji", ":IPython<CR>", { desc = "Start IPython" })
vim.keymap.set("n", "<leader>jr", "<Plug>(IPy-Run)", { desc = "Run cell" })
