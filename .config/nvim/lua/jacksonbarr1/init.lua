require("jacksonbarr1.options")
require("jacksonbarr1.remap")
require("jacksonbarr1.lazy_init")

require("catppuccin").setup({
	flavour = "frappe",
	transparent_background = true,
})

vim.cmd.colorscheme("catppuccin-frappe")

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(event)
		local map = function(keys, func, desc, mode)
			mode = mode or "n"
			vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end

		map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
	end,
})
