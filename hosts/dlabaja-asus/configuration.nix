{ pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.grub.gfxmodeEfi = "1920x1200x32";

  networking.hostName = "dlabaja-asus";

  environment.systemPackages = [
    pkgs.gnomeExtensions.battery-health-charging
  ];

  system.stateVersion = "24.11";
}
