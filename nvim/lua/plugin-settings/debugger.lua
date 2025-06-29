local dap = require("dap")
local dapui = require("dapui")

dapui.setup()

-- Python DAP
require("dap-python").setup("python")

-- C++ DAP
dap.adapters.cppdbg = {
    id = "cppdbg",
    type = "executable",
    command = "gdb",
}
dap.configurations.cpp = {
    {
        name = "Launch",
        type = "cppdbg",
        request = "launch",
        program = "${workspaceFolder}/a.out",
        cwd = "${workspaceFolder}",
        stopAtEntry = true,
    },
}

-- Keymaps
vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug continue" })
vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Step over" })
vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Step into" })
vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Toggle DAP UI" })
