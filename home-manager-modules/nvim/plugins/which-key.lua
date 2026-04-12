require("which-key").setup({
	delay = 0,
	spec = {
		{ '<leader>s', group = '[S]earch',   mode = { 'n', 'v' } },
		{ '<leader>t', group = '[T]oggle' },
		{ '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
		{ 'gr',        group = 'LSP Actions', mode = { 'n' } },
	},
})
