return {
	"stevearc/conform.nvim",
	event = { "BufWritePre", "BufNewFile" },
	cmd = "ConformInfo",
	keys = {
		{
			"<leader>f",
			function()
				require("conform").format({ async = true })
			end,
			mode = "",
			desc = "Format buffer",
		},
	},

	config = function()
		require("conform").setup({
			format_on_save = function()
				if vim.g.disable_autoformat then
					return
				end
				return { timeout_ms = 500, lsp_fallback = true, async = false }
			end,
			default_format_opts = {
				lsp_format = "fallback",
			},
			formatters_by_ft = {
				lua = { "stylua" },
			},
		})
	end,
}
