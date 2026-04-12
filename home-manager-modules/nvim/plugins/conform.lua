require("conform").setup({
	formatters_by_ft = {
		c      = { "clang_format" },
		cpp    = { "clang_format" },
		python = { "ruff_format" },
		nix    = { "alejandra" },
		lua    = { "stylua" },
	},
	format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
})

vim.keymap.set({ 'n', 'v' }, '<leader>f', function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = '[F]ormat buffer' })
