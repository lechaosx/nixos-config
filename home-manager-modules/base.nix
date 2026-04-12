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
			enable        = true;
			defaultEditor = true;

			extraPackages = with pkgs; [
				clang-tools           # clangd + clang-format for C/C++
				pyright               # Python LSP
				ruff                  # Python formatter
				nixd                  # Nix LSP
				alejandra             # Nix formatter
				lua-language-server   # Lua LSP
				stylua                # Lua formatter
				cmake-language-server # CMake LSP
			];

			plugins = with pkgs.vimPlugins; [
				# Theme
				{ plugin = catppuccin-nvim;   type = "lua"; config = builtins.readFile ./nvim/plugins/catppuccin.lua; }
				# Icons
				nvim-web-devicons
				# Syntax highlighting
				nvim-treesitter.withAllGrammars
				# Status bar
				{ plugin = lualine-nvim;      type = "lua"; config = builtins.readFile ./nvim/plugins/lualine.lua; }
				# Keybinding helper
				{ plugin = which-key-nvim;    type = "lua"; config = builtins.readFile ./nvim/plugins/which-key.lua; }
				# Fuzzy finder
				plenary-nvim
				{ plugin = telescope-nvim;    type = "lua"; config = builtins.readFile ./nvim/plugins/telescope.lua; }
				# Autopairs
				{ plugin = nvim-autopairs;    type = "lua"; config = builtins.readFile ./nvim/plugins/autopairs.lua; }
				# Guess indent
				{ plugin = guess-indent-nvim; type = "lua"; config = builtins.readFile ./nvim/plugins/guess-indent.lua; }
				# Git signs
				{ plugin = gitsigns-nvim; type = "lua"; config = builtins.readFile ./nvim/plugins/gitsigns.lua; }
				# Mini
				{ plugin = mini-nvim;         type = "lua"; config = builtins.readFile ./nvim/plugins/mini.lua; }
				# LSP (data plugin - server configs; behavior is in nvim/init.lua)
				nvim-lspconfig
				# Formatter
				{ plugin = conform-nvim;      type = "lua"; config = builtins.readFile ./nvim/plugins/conform.lua; }
				# LSP progress spinner
				{ plugin = fidget-nvim;       type = "lua"; config = builtins.readFile ./nvim/plugins/fidget.lua; }
				# TODO comments
				{ plugin = todo-comments-nvim; type = "lua"; config = builtins.readFile ./nvim/plugins/todo-comments.lua; }
				# Completions
				luasnip
				{ plugin = blink-cmp;         type = "lua"; config = builtins.readFile ./nvim/plugins/blink.lua; }
			];

			extraLuaConfig = builtins.readFile ./nvim/init.lua;
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
