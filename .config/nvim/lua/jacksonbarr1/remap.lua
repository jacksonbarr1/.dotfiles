local map = vim.keymap.set

map("n", "<left>", '<cmd>echo "Use h to move left"<CR>')
map("n", "<right>", '<cmd>echo "Use l to move right"<CR>')
map("n", "<up>", '<cmd>echo "Use k to move up"<CR>')
map("n", "<down>", '<cmd>echo "Use j to move down"<CR>')

map("n", "<leader>L", "<cmd>Lazy<CR>", { desc = "Open Lazy UI" })

map("n", "<leader>fD",
  function()
    local is_enabled = vim.diagnostic.is_enabled()
    vim.diagnostic.enable(not is_enabled)
    vim.notify(is_enabled and "Diagnostics Disabled" or "Diagnostics Enabled", vim.log.levels.INFO)
  end,
  { desc = "Toggle Diagnostics", silent = true }
)
