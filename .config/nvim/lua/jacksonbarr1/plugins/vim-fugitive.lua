return {
    "tpope/vim-fugitive",
    config = function()
        vim.keymap.set("n", "<leader>gs", ":Git<CR>", { noremap = true, desc = "git status" })
        vim.keymap.set("n", "<leader>ga", ":Git add ", { noremap = true, desc = "git add" })
        vim.keymap.set('n', '<leader>gA',':Git add .<CR>', {noremap = true, desc ='git add .' })
        vim.keymap.set('n', '<leader>gc',':Git commit -qam "',{noremap = true, desc = 'git commit -am' })
        vim.keymap.set("n", "<leader>gp", ":Git push <CR>", { noremap = true, desc = "git push" })
    end
}
