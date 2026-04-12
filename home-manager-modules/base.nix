{ pkgs, ... }:
{
	home.username = "dlabaja";
	home.homeDirectory = "/home/dlabaja";

	home.packages = with pkgs; [
		vlc
		spotify
		jetbrains.clion
		jetbrains.pycharm
		gitkraken
		gnomeExtensions.vitals
		cmake
		ninja
	];

	home.sessionPath = [ "$HOME/.local/bin" ];

	programs = {
		git = {
			enable = true;
			lfs.enable = true;
			signing.format = "openpgp";
		};

		bash = {
			enable = true;
			historySize = 10000;
			historyControl = [ "ignoredups" "erasedups" ];
			initExtra = ''
				PROMPT_COMMAND="history -a"
			'';
		};

		uv.enable = true;

		fzf.enable = true;
		ripgrep.enable = true;
		btop.enable = true;
		tmux.enable = true;
		gcc.enable = true;
		claude-code.enable = true;

		neovim = {
			enable = true;
			defaultEditor = true;

			extraPackages = with pkgs; [
				clang-tools  # clangd + clang-format for C/C++
				pyright      # Python LSP
				ruff         # Python formatter
			];

			plugins = with pkgs.vimPlugins; [
				# Theme
				{
					plugin = catppuccin-nvim;
					type = "lua";
					config = ''
						vim.cmd.colorscheme("catppuccin")
					'';
				}
				# Icons
				nvim-web-devicons
				# Syntax highlighting
				nvim-treesitter.withAllGrammars
				# Status bar
				{
					plugin = lualine-nvim;
					type = "lua";
					config = ''require("lualine").setup()'';
				}
				# Keybinding helper
				which-key-nvim
				# Fuzzy finder
				plenary-nvim
				{
					plugin = telescope-nvim;
					type = "lua";
					config = ''
						local builtin = require("telescope.builtin")
						require("telescope").setup()
						vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
						vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
						vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
						vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
						vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
						vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
						vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
						vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
						vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
						vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
						vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

						vim.api.nvim_create_autocmd('LspAttach', {
							group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
							callback = function(event)
								local buf = event.buf
								vim.keymap.set('n', 'grr', builtin.lsp_references,               { buffer = buf, desc = '[G]oto [R]eferences' })
								vim.keymap.set('n', 'gri', builtin.lsp_implementations,          { buffer = buf, desc = '[G]oto [I]mplementation' })
								vim.keymap.set('n', 'grd', builtin.lsp_definitions,              { buffer = buf, desc = '[G]oto [D]efinition' })
								vim.keymap.set('n', 'gO',  builtin.lsp_document_symbols,         { buffer = buf, desc = 'Open Document Symbols' })
								vim.keymap.set('n', 'gW',  builtin.lsp_dynamic_workspace_symbols,{ buffer = buf, desc = 'Open Workspace Symbols' })
								vim.keymap.set('n', 'grt', builtin.lsp_type_definitions,         { buffer = buf, desc = '[G]oto [T]ype Definition' })
							end,
						})
					'';
				}
				# Autopairs
				{
					plugin = nvim-autopairs;
					type = "lua";
					config = ''require("nvim-autopairs").setup()'';
				}
				# Guess indent
				{
					plugin = guess-indent-nvim;
					type = "lua";
					config = ''require("guess-indent").setup()'';
				}
				# Gitsigns
				gitsigns-nvim
				# Mini
				{
					plugin = mini-nvim;
					type = "lua";
					config = ''
						require("mini.ai").setup()
						require("mini.surround").setup()
					'';
				}
				# LSP (data plugin - server configs; behavior is in initLua)
				nvim-lspconfig
				# Formatter
				{
					plugin = conform-nvim;
					type = "lua";
					config = ''
						require("conform").setup({
							formatters_by_ft = {
								c   = { "clang_format" },
								cpp = { "clang_format" },
								python = { "ruff_format" },
							},
							format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
						})
						vim.keymap.set({ 'n', 'v' }, '<leader>f', function()
							require("conform").format({ async = true, lsp_format = "fallback" })
						end, { desc = '[F]ormat buffer' })
					'';
				}
				# TODO comments
				todo-comments-nvim
				# Completions
				luasnip
				{
					plugin = blink-cmp;
					type = "lua";
					config = ''require("blink.cmp").setup({})'';
				}
			];

			initLua = ''
				-- Leader key
				vim.g.mapleader = ' '
				vim.g.maplocalleader = ' '

				-- Indentation
				vim.opt.tabstop     = 4
				vim.opt.shiftwidth  = 4

				-- Line numbers
				vim.opt.number = true
				vim.opt.relativenumber = true

				-- 120-char ruler
				vim.opt.colorcolumn = "120"

				-- Show whitespace (tabs, trailing spaces, overflow indicators)
				vim.opt.list = true
				vim.opt.listchars = { tab = "→ ", trail = "•", nbsp = "○", precedes = "«", extends = "»" }

				-- Disable arrow keys (use hjkl)
				local no_arrows = { "<Up>", "<Down>", "<Left>", "<Right>" }
				for _, key in ipairs(no_arrows) do
					vim.keymap.set({ "n", "i", "v" }, key, "<Nop>", { desc = "Use hjkl" })
				end
				
				vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

				-- QoL
				vim.opt.mouse = a
				vim.opt.showmode = false
				vim.opt.breakindent = true
				vim.opt.undofile = true
				vim.opt.ignorecase = true
				vim.opt.smartcase = true
				vim.opt.signcolumn = "yes"
				vim.opt.updatetime = 250
				vim.opt.timeoutlen = 300
				vim.opt.splitright = true
				vim.opt.splitbelow = true
				vim.opt.inccommand = 'split'
				vim.opt.clipboard  = "unnamedplus"
				vim.opt.scrolloff  = 8
				vim.opt.cursorline = true

				-- Diagnostic Config & Keymaps
				vim.diagnostic.config {
					update_in_insert = false,
					severity_sort = true,
					float = { border = 'rounded', source = 'if_many' },
					underline = { severity = { min = vim.diagnostic.severity.WARN } },

					-- Can switch between these as you prefer
					virtual_text = true, -- Text shows up at the end of the line
					virtual_lines = false, -- Text shows up underneath the line, with virtual lines

					-- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
					jump = { float = true },
				}

				vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

				-- LSP servers (binaries provided via extraPackages)
				vim.lsp.enable({ 'clangd', 'pyright' })

				vim.api.nvim_create_autocmd('LspAttach', {
					group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
					callback = function(event)
						local map = function(keys, func, desc, mode)
							vim.keymap.set(mode or 'n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
						end

						map('grn', vim.lsp.buf.rename,      '[R]e[n]ame')
						map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
						map('grD', vim.lsp.buf.declaration,  '[G]oto [D]eclaration')

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
					desc = 'Highlight when yanking (copying) text',
					group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
					callback = function() vim.hl.on_yank() end,
				})
			'';
		};
	};

	services.remmina.enable = true;

	dconf.settings = {
		"org/gnome/desktop/interface" = {
			clock-show-seconds = true;
		};
		"org/gnome/desktop/input-sources" = {
			sources = [(pkgs.lib.gvariant.mkTuple ["xkb" "us"]) (pkgs.lib.gvariant.mkTuple ["xkb" "cz"])];
			per-window = true;
		};
		"org/gnome/desktop/wm/keybindings" = {
			switch-input-source = ["<Shift>Alt_L"];
			switch-input-source-backward = ["<Alt>Shift_L"];
		};
		"org/gnome/desktop/wm/preferences" = {
			button-layout = "appmenu:minimize,maximize,close";
		};
		"org/gnome/desktop/app-folders" = {
			folder-children = [""];
		};
		"org/gnome/shell" = {
			app-picker-layout = [""];
		};
	};

}
