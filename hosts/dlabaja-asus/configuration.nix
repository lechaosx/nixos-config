# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

{
	imports = [
		./hardware-configuration.nix
	];

	nix = {
		settings = {
			auto-optimise-store = true;
			experimental-features = [ "nix-command" "flakes" ];
		};

		gc = {
			automatic = true;
			dates = "weekly";
			options = "--delete-older-than 1w";
		};
	};

	boot.loader = {
		systemd-boot.enable = true;
		efi.canTouchEfiVariables = true;
	};

	networking = {
		hostName = "dlabaja-asus";
		networkmanager.enable = true;
	};

	time.timeZone = "Europe/Prague";

	i18n = {
		# Sets language to english
		defaultLocale = "en_US.UTF-8";

		# Sets formats of everything to czech
		extraLocaleSettings = {
			LC_ADDRESS = "cs_CZ.UTF-8";
			LC_IDENTIFICATION = "cs_CZ.UTF-8";
			LC_MEASUREMENT = "cs_CZ.UTF-8";
			LC_MONETARY = "cs_CZ.UTF-8";
			LC_NAME = "cs_CZ.UTF-8";
			LC_NUMERIC = "cs_CZ.UTF-8";
			LC_PAPER = "cs_CZ.UTF-8";
			LC_TELEPHONE = "cs_CZ.UTF-8";
			LC_TIME = "cs_CZ.UTF-8";
		};
	};

	services = {
		xserver = {
			enable = true;
			displayManager.gdm.enable = true;
			desktopManager.gnome.enable = true;
		};

		printing.enable = true;

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

	environment = {
		systemPackages = [
			pkgs.gnomeExtensions.power-profile-switcher
			pkgs.gnomeExtensions.battery-health-charging
		];

		gnome.excludePackages = [
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
	};

	users.users.dlabaja = {
		isNormalUser = true;
		description = "Drahomír Dlabaja";
		extraGroups = [ "networkmanager" "wheel" "docker" ];
	};

	programs = {
		firefox.enable = true;

		steam = {
			enable = true;
			remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
			dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
			localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
		};
	};

	nixpkgs.config.allowUnfree = true;

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "24.11"; # Did you read the comment?

}
