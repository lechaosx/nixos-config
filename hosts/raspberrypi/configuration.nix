{
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
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

  users.users.dlabaja = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keyFiles = [ ./authorized_keys ];
  };
  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  users.users.github = {
    isNormalUser = true;
    linger = true;
    openssh.authorizedKeys.keyFiles = [ ./github_authorized_keys ];
  };
  virtualisation.podman.enable = true;

  system.stateVersion = "26.11";
}
