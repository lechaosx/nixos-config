{ pkgs, ... }:
{
	nixpkgs.config.allowUnfree = true;

	home.username = "dlabaja";
	home.homeDirectory = "/home/dlabaja";

	home.packages = with pkgs; [
		vlc
		btop
		discord
		spotify
		transmission_4-gtk
	];

	programs = {
		vscode.enable = true;
		firefox.enable = true;

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
	};

	home.stateVersion = "24.11";
}
