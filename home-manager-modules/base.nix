{ pkgs, ... }:
{
	home.username = "dlabaja";
	home.homeDirectory = "/home/dlabaja";

	home.packages = with pkgs; [
		ripgrep
		vlc
		btop
		spotify
		jetbrains.clion
		jetbrains.pycharm
		remmina
		gitkraken
		gnomeExtensions.vitals
		gcc
		cmake
		ninja
		claude-code
	];

	home.sessionPath = [ "$HOME/.local/bin" ];

	programs = {
		vscode = {
			enable = true;
			package = pkgs.vscode.fhs;
		};

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

		neovim = {
			enable = true;
			defaultEditor = true;

			extraPackages = with pkgs; [
				clang-tools  # clangd for C/C++
				pyright      # Python
			];

			plugins = with pkgs.vimPlugins; [
				# Theme
				{
					plugin = catppuccin-nvim;
					type = "lua";
					config = ''
						require("catppuccin").setup({ flavour = "mocha" })
						vim.cmd.colorscheme("catppuccin")
					'';
				}
				# Icons
				nvim-web-devicons
				# File tree
				{
					plugin = nvim-tree-lua;
					type = "lua";
					config = ''
						require("nvim-tree").setup({
							view    = { width = 35, side = "left" },
							filters = { dotfiles = false },
						})
						vim.keymap.set("n", "<C-b>", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree" })
					'';
				}
				# Syntax highlighting
				nvim-treesitter.withAllGrammars
				# Status bar
				{
					plugin = lualine-nvim;
					type = "lua";
					config = ''require("lualine").setup()'';
				}
				# Keybinding helper
				{
					plugin = which-key-nvim;
					type = "lua";
					config = ''require("which-key").setup()'';
				}
				# Fuzzy finder
				plenary-nvim
				{
					plugin = telescope-nvim;
					type = "lua";
					config = ''
						local builtin = require("telescope.builtin")
						require("telescope").setup()
						vim.keymap.set("n", "<C-p>",      builtin.find_files,  { desc = "Find files" })
						vim.keymap.set("n", "<C-S-f>",    builtin.live_grep,   { desc = "Search in files" })
						vim.keymap.set("n", "<leader>fb", builtin.buffers,     { desc = "Find buffers" })
						vim.keymap.set("n", "<leader>fr", builtin.oldfiles,    { desc = "Recent files" })
					'';
				}
				# Completion
				cmp-nvim-lsp
				cmp-buffer
				cmp-path
				cmp_luasnip
				friendly-snippets
				luasnip
				{
					plugin = nvim-cmp;
					type = "lua";
					config = ''
						local cmp     = require("cmp")
						local luasnip = require("luasnip")
						require("luasnip.loaders.from_vscode").lazy_load()

						cmp.setup({
							snippet = {
								expand = function(args) luasnip.lsp_expand(args.body) end,
							},
							mapping = cmp.mapping.preset.insert({
								["<C-Space>"] = cmp.mapping.complete(),
								["<C-e>"]     = cmp.mapping.abort(),
								["<CR>"]      = cmp.mapping.confirm({ select = true }),
								["<Tab>"] = cmp.mapping(function(fallback)
									if cmp.visible() then cmp.select_next_item()
									elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
									else fallback() end
								end, { "i", "s" }),
								["<S-Tab>"] = cmp.mapping(function(fallback)
									if cmp.visible() then cmp.select_prev_item()
									elseif luasnip.jumpable(-1) then luasnip.jump(-1)
									else fallback() end
								end, { "i", "s" }),
							}),
							sources = cmp.config.sources({
								{ name = "nvim_lsp" },
								{ name = "luasnip" },
								{ name = "buffer" },
								{ name = "path" },
							}),
						})
					'';
				}
				# Editor helpers
				{
					plugin = nvim-autopairs;
					type = "lua";
					config = ''require("nvim-autopairs").setup()'';
				}
				{
					plugin = bufferline-nvim;
					type = "lua";
					config = ''
						require("bufferline").setup({ options = { diagnostics = "nvim_lsp" } })
						vim.keymap.set("n", "<Tab>",     "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
						vim.keymap.set("n", "<S-Tab>",   "<cmd>BufferLineCyclePrev<CR>", { desc = "Prev buffer" })
						vim.keymap.set("n", "<leader>x", "<cmd>bdelete<CR>",             { desc = "Close buffer" })
					'';
				}
				{
					plugin = comment-nvim;
					type = "lua";
					config = ''require("Comment").setup()'';
				}
			];

			initLua = ''
				-- Line numbers
				vim.opt.number = true
				vim.opt.relativenumber = true

				-- 120-char ruler
				vim.opt.colorcolumn = "120"
				vim.opt.textwidth = 120

				-- Show whitespace (tabs, trailing spaces, overflow indicators)
				vim.opt.list = true
				vim.opt.listchars = { tab = "→ ", trail = "•", nbsp = "○", precedes = "«", extends = "»" }

				-- QoL
				vim.opt.clipboard  = "unnamedplus"
				vim.opt.scrolloff  = 8
				vim.opt.cursorline = true

				-- LSP (neovim 0.11 built-in API)
				local capabilities = require("cmp_nvim_lsp").default_capabilities()

				vim.lsp.config("clangd", {
					cmd          = { "clangd" },
					filetypes    = { "c", "cpp", "objc", "objcpp", "cuda" },
					root_markers = { ".clangd", "compile_commands.json", ".git" },
					capabilities = capabilities,
				})

				vim.lsp.config("pyright", {
					cmd          = { "pyright-langserver", "--stdio" },
					filetypes    = { "python" },
					root_markers = { "pyproject.toml", "setup.py", ".git" },
					capabilities = capabilities,
				})

				vim.lsp.enable({ "clangd", "pyright" })

				vim.api.nvim_create_autocmd("LspAttach", {
					callback = function(event)
						local b = event.buf
						vim.keymap.set("n", "gd",         vim.lsp.buf.definition,                              { buffer = b, desc = "Go to definition" })
						vim.keymap.set("n", "gr",         vim.lsp.buf.references,                              { buffer = b, desc = "References" })
						vim.keymap.set("n", "K",          vim.lsp.buf.hover,                                   { buffer = b, desc = "Hover docs" })
						vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,                                  { buffer = b, desc = "Rename symbol" })
						vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action,                             { buffer = b, desc = "Code action" })
						vim.keymap.set("n", "<leader>f",  function() vim.lsp.buf.format({ async = true }) end, { buffer = b, desc = "Format file" })
						vim.keymap.set("n", "[d",         vim.diagnostic.goto_prev,                            { buffer = b, desc = "Prev diagnostic" })
						vim.keymap.set("n", "]d",         vim.diagnostic.goto_next,                            { buffer = b, desc = "Next diagnostic" })
					end,
				})
			'';
		};
	};

	dconf.settings = {
		"org/gnome/desktop/interface" = {
			clock-show-seconds = true;
		};
		"org/gnome/desktop/input-sources" = {
			sources = [(pkgs.lib.gvariant.mkTuple ["xkb" "us"]) (pkgs.lib.gvariant.mkTuple ["xkb" "cz"])];
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
