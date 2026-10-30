{
  lib,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
    ./users/dlabaja
    ./users/github
  ];

  disabledModules = [ "profiles/base.nix" ];
  nixpkgs.hostPlatform = "aarch64-linux";

  hardware.enableAllHardware = lib.mkForce false;
  boot.initrd.availableKernelModules = [
    "usbhid"
    "usb_storage"
    "vc4"
  ];

  networking = {
    hostName = "raspberrypi";
    usePredictableInterfaceNames = false;
    useDHCP = false;
    interfaces.eth0.useDHCP = true;
    firewall = {
      allowedTCPPorts = [
        8080
        8443
      ];
      allowedUDPPorts = [ 8443 ];
    };
  };

  time.timeZone = "Europe/Prague";
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  zramSwap.enable = true;
  services.journald.settings.Journal.SystemMaxUse = "100M";

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  virtualisation.podman.enable = true;
  environment.systemPackages = [ pkgs.podman-compose ];
  virtualisation.containers.containersConf.settings.engine.compose_providers = [
    (lib.getExe pkgs.podman-compose)
  ];
  systemd.sockets.podman.enable = false;
  systemd.user.sockets.podman.enable = false;

  system.stateVersion = "26.11";
}
