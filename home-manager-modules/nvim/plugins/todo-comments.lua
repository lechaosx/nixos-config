require("todo-comments").setup({ signs = false })

vim.keymap.set('n', ']t', function() require("todo-comments").jump_next() end, { desc = 'Next [T]odo comment' })
vim.keymap.set('n', '[t', function() require("todo-comments").jump_prev() end, { desc = 'Previous [T]odo comment' })
vim.keymap.set('n', '<leader>st', '<cmd>TodoTelescope<cr>', { desc = '[S]earch [T]odo comments' })
