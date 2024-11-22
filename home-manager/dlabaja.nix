{ pkgs, ... }:
{
	nixpkgs.config.allowUnfree = true;

	home.username = "dlabaja";
	home.homeDirectory = "/home/dlabaja";

	home.packages = with pkgs; [
		vlc
		btop
		git
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

	home.stateVersion = "24.11";
}
