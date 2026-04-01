{ pkgs, ... }:
{
	home.username = "dlabaja";
	home.homeDirectory = "/home/dlabaja";

	home.packages = with pkgs; [
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
			extraConfig = ''
				set number relativenumber
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
