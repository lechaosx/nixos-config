-- Leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Line numbers
vim.opt.number         = true
vim.opt.relativenumber = true

-- Show whitespace (tabs, trailing spaces, overflow indicators)
vim.opt.list      = true
vim.opt.listchars = { tab = "→ ", trail = "•", nbsp = "○", precedes = "«", extends = "»" }

-- Disable arrow keys (use hjkl)
for _, key in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>" }) do
	vim.keymap.set({ "n", "i", "v" }, key, "<Nop>", { desc = "Use hjkl" })
end

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- QoL
vim.opt.mouse       = 'a'
vim.opt.showmode    = false
vim.opt.breakindent = true
vim.opt.tabstop     = 4
vim.opt.shiftwidth  = 4
vim.opt.undofile    = true
vim.opt.ignorecase  = true
vim.opt.smartcase   = true
vim.opt.signcolumn  = "yes"
vim.opt.updatetime  = 250
vim.opt.timeoutlen  = 300
vim.opt.splitright  = true
vim.opt.splitbelow  = true
vim.opt.confirm     = true
vim.opt.inccommand  = 'split'
vim.opt.clipboard   = "unnamedplus"
vim.opt.scrolloff   = 8
vim.opt.cursorline  = true

-- Diagnostic config
vim.diagnostic.config({
	update_in_insert = false,
	severity_sort    = true,
	float            = { border = 'rounded', source = 'if_many' },
	underline        = { severity = { min = vim.diagnostic.severity.WARN } },
	virtual_text     = true,  -- text at end of line
	virtual_lines    = false, -- text underneath the line
	jump             = { float = true }, -- auto-open float when jumping with [d/]d
})

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- LSP servers (binaries provided via extraPackages in Nix)
vim.lsp.enable({ 'clangd', 'pyright', 'nixd', 'lua_ls', 'cmake' })

vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
	callback = function(event)
		local map = function(keys, func, desc, mode)
			vim.keymap.set(mode or 'n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
		end

		map('grn', vim.lsp.buf.rename,      '[R]e[n]ame')
		map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
		map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

		-- Highlight all references to symbol under cursor
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client and client:supports_method('textDocument/documentHighlight', event.buf) then
			local group = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
			vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
				buffer = event.buf, group = group,
				callback = vim.lsp.buf.document_highlight,
			})
			vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
				buffer = event.buf, group = group,
				callback = vim.lsp.buf.clear_references,
			})
			vim.api.nvim_create_autocmd('LspDetach', {
				group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
				callback = function(event2)
					vim.lsp.buf.clear_references()
					vim.api.nvim_clear_autocmds({ group = 'lsp-highlight', buffer = event2.buf })
				end,
			})
		end

		-- Toggle inlay hints (e.g. parameter names, return types)
		if client and client:supports_method('textDocument/inlayHint', event.buf) then
			map('<leader>th', function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
			end, '[T]oggle Inlay [H]ints')
		end
	end,
})

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
	desc     = 'Highlight when yanking (copying) text',
	group    = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
	callback = function() vim.hl.on_yank() end,
})
