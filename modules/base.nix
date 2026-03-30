{ pkgs, ... }:
{
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

	networking.networkmanager.enable = true;

	users.users.dlabaja = {
		isNormalUser = true;
		description = "Drahomír Dlabaja";
		extraGroups = [ "networkmanager" "wheel" "docker" ];
	};

	programs = {
		firefox.enable = true;

		nix-ld = {
			enable = true;
			libraries = [ pkgs.stdenv.cc.cc ];
		};
	};

	nixpkgs.config.allowUnfree = true;
}
