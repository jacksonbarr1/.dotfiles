local diagnostic_icons = {
	ERROR = " ",
	WARN = " ",
	HINT = " ",
	INFO = " ",
}

return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"stevearc/conform.nvim",
		"mason-org/mason.nvim",
		"mason-org/mason-lspconfig.nvim",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"hrsh7th/nvim-cmp",
		"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip",
		"zbirenbaum/copilot-cmp",
	},
	config = function()
		require("conform").setup({})

		local cmp = require("cmp")
		local cmp_lsp = require("cmp_nvim_lsp")
		local copilot = require("copilot_cmp").setup()
		local capabilities = vim.tbl_deep_extend(
			"force",
			{},
			vim.lsp.protocol.make_client_capabilities(),
			cmp_lsp.default_capabilities()
		)

		local kind_icons = {
			Text = "󰉿",
			Method = "m",
			Function = "󰊕",
			Constructor = "",
			Field = "",
			Variable = "󰆧",
			Class = "󰌗",
			Interface = "",
			Module = "",
			Property = "",
			Unit = "",
			Value = "󰎠",
			Enum = "",
			Keyword = "󰌋",
			Snippet = "",
			Color = "󰏘",
			File = "󰈙",
			Reference = "",
			Folder = "󰉋",
			EnumMember = "",
			Constant = "󰇽",
			Struct = "",
			Event = "",
			Operator = "󰆕",
			TypeParameter = "󰊄",
			Copilot = "",
		}

		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = {
				"lua_ls",
			},
			handlers = {
				function(server_name)
					require("lspconfig")[server_name].setup({
						capabilities = capabilities,
					})
				end,
				["lua_ls"] = function()
					local lspconfig = require("lspconfig")
					lspconfig.lua_ls.setup({
						capabilities = capabilities,
						settings = {
							Lua = {
								format = {
									enable = true,
									defaultConfig = {
										indent_style = "space",
										indent_size = "2",
									},
								},
							},
						},
					})
				end,
			},
		})

		local cmp_select = { behavior = cmp.SelectBehavior.Select }

		cmp.setup({
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body)
				end,
			},
			completion = {
				completeopt = "menu,menuone,noinsert",
			},
			mapping = cmp.mapping.preset.insert({
				["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
				["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
				["<C-y>"] = cmp.mapping.confirm({ select = true }),
				["<C-Space>"] = cmp.mapping.complete(),
			}),
			sources = cmp.config.sources({
				{ name = "copilot", priority = 100, max_item_count = 3 },
				{ name = "nvim_lsp", max_item_count = 7 },
				{ name = "luasnip" },
				{ name = "path" },
			}, {
				{ name = "buffer" },
			}),
			formatting = {
				format = function(entry, vim_item)
					vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind)
					vim_item.menu = ({
						buffer = "[Buffer]",
						nvim_lsp = "[LSP]",
						luasnip = "[LuaSnip]",
						path = "[Path]",
						copilot = "[Copilot]",
					})[entry.source.name]
					return vim_item
				end,
			},
		})

		vim.diagnostic.config({
			virtual_text = {
				severity = nil,
				source = "if_many",
				format = function(diagnostic)
					local reduced = { ["Lua Diagnostics."] = "", ["Lua Syntax Check."] = "" }
					local msg = diagnostic_icons[vim.diagnostic.severity[diagnostic.severity]]
					if reduced[diagnostic.message] ~= nil then
						return msg .. " " .. reduced[diagnostic.message]
					end
					return msg .. " " .. diagnostic.message
				end,
				prefix = "",
				spacing = 4,
			},
			float = {
				border = "rounded",
				source = false,
				format = function(diagnostic)
					return diagnostic.message
				end,
				prefix = function(diagnostic)
					local level = vim.diagnostic.severity[diagnostic.severity]
					local pref = string.format(" %s ", diagnostic_icons[level])
					return pref, "Diagnostic" .. level:gsub("^%1", string.upper)
				end,
			},
			signs = false,
		})
	end,
}
