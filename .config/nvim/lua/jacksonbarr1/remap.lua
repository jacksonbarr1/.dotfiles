local map = vim.keymap.set

map("n", "<left>", '<cmd>echo "Use h to move left"<CR>')
map("n", "<right>", '<cmd>echo "Use l to move right"<CR>')
map("n", "<up>", '<cmd>echo "Use k to move up"<CR>')
map("n", "<down>", '<cmd>echo "Use j to move down"<CR>')

vim.api.nvim_create_user_command("AutoformatToggle", function(args)
	if vim.g.disable_autoformat then
		vim.g.disable_autoformat = false
	else
		vim.g.disable_autoformat = true
	end
end, {
	desc = "Toggle autoformat-on-save",
})

map("n", "<leader>fd", ":AutoformatToggle<CR>")
