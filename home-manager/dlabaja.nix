{ pkgs, ... }:
{
	nixpkgs.config = {
		allowUnfree = true;
	};

	home.username = "dlabaja";
	home.homeDirectory = "/home/dlabaja";

	home.packages = with pkgs; [
		vlc
		btop
		discord
		spotify
		transmission_4-gtk
		jetbrains.clion
		remmina
		gnomeExtensions.freon
	];

	programs = {
		vscode = {
			enable = true;
			package = pkgs.vscode.fhs;
		};

		git = {
			enable = true;
			userName = "Drahomír Dlabaja";
			userEmail = "lechaosx@gmail.com";
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

	home.stateVersion = "24.11";
}
