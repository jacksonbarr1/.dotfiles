return {
    "saghen/blink.cmp",
    dependencies = {
        "rafamadriz/friendly-snippets",
    },
    build = "cargo +nightly build --release",
    opts = {
        fuzzy = {
            implementation = "prefer_rust"
        },
        completion = {
            documentation = {
                auto_show = true
            }
        },
        sources = {
            default = { "lsp", "path", "snippets", "buffer" }
        },
        signature = { enabled = true },
    },
    opts_extend = { "sources.default" }
},
