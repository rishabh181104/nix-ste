require("lint").linters_by_ft = { --some of these need to be installed from package manager
  lua = { "luac" },
  python = { "ruff" },
  sh = { "shellcheck" },
  c = { "cppcheck" },
  rust = { "clippy" },
  css = { "stylelint" },
  html = { "htmlhint" },
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    require("lint").try_lint()
  end,
})
