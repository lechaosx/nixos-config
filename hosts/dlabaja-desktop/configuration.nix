{ pkgs, customModules, ... }:
{
	imports = [
		./hardware-configuration.nix
		customModules.base
		customModules.desktop
		customModules.grub
	];

	grub.gfxmodeEfi = "1920x1080x32";

	networking = {
		hostName = "dlabaja-desktop";
		interfaces.enp4s0.wakeOnLan.enable = true;
	};

	services = {
		gnome.gnome-remote-desktop.enable = true;

		xserver.videoDrivers = ["nvidia"];

		displayManager.gdm.autoSuspend = false;

		openssh = {
			enable = true;
			settings = {
				PasswordAuthentication = false;
				UseDns = true;
				X11Forwarding = true;
				PermitRootLogin = "no";
			};
		};

		power-profiles-daemon.enable = false; # Override default gnome setting
	};

	systemd.services."gnome-remote-desktop".wantedBy = [ "graphical.target" ];

	environment.systemPackages = [
		pkgs.gnomeExtensions.allow-locked-remote-desktop
	];

	hardware = {
		graphics.enable = true;

		nvidia = {
			open = false;
			powerManagement.enable = true;
		};
	};

	virtualisation.docker.enable = true;

	system.stateVersion = "24.05";
}
