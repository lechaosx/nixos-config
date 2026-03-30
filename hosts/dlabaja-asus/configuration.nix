{ pkgs, customModules, ... }:
{
	imports = [
		./hardware-configuration.nix
		customModules.base
		customModules.desktop
		customModules.grub
	];

	grub.gfxmodeEfi = "1920x1200x32";

	networking.hostName = "dlabaja-asus";

	environment.systemPackages = [
		# Broken as of 20. 4. 2025
		# pkgs.gnomeExtensions.power-profile-switcher
		pkgs.gnomeExtensions.battery-health-charging
	];

	system.stateVersion = "24.11";
}
