{ pkgs, ... }:
{
	services = {
		xserver = {
			enable = true;
			excludePackages = [ pkgs.xterm ];
		};

		displayManager.gdm.enable = true;
		desktopManager.gnome.enable = true;

		pipewire = {
			enable = true;
			alsa = {
				enable = true;
				support32Bit = true;
			};
			pulse.enable = true;
		};
	};

	security.rtkit.enable = true;

	environment.gnome.excludePackages = [
		pkgs.gnome-tour
		pkgs.baobab
		pkgs.epiphany
		pkgs.gnome-calendar
		pkgs.gnome-characters
		pkgs.gnome-clocks
		pkgs.gnome-connections
		pkgs.gnome-contacts
		pkgs.gnome-font-viewer
		pkgs.gnome-maps
		pkgs.gnome-music
		pkgs.gnome-weather
		pkgs.simple-scan
		pkgs.totem
		pkgs.yelp
		pkgs.file-roller
		pkgs.geary
		pkgs.seahorse
		pkgs.sushi
	];

	programs.steam = {
		enable = true;
		remotePlay.openFirewall = true;
		dedicatedServer.openFirewall = true;
		localNetworkGameTransfers.openFirewall = true;
	};
}
