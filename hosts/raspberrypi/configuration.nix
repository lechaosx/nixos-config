{
  lib,
  modulesPath,
  pkgs,
  ...
}:
let
  publicAddress = "boats.dlabaja.eu";
in
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
      allowedTCPPorts = [ 80 ];
      allowedUDPPorts = [ 8765 ];
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

  users.groups.pyboat = { };
  users.users.pyboat = {
    isSystemUser = true;
    group = "pyboat";
  };
  systemd.tmpfiles.rules = [ "d /var/lib/pyboat 0755 root root -" ];

  security.acme = {
    acceptTerms = true;
    certs.pyboat = {
      domain = publicAddress;
      listenHTTP = ":80";
      group = "pyboat";
      profile = "shortlived";
      renewInterval = "*-*-* 00,12:00:00";
      renewJitter = "1h";
      postRun = "${pkgs.systemd}/bin/systemctl --no-block try-reload pyboat.service";
    };
  };
  systemd.timers.acme-renew-pyboat.timerConfig.AccuracySec = lib.mkForce "1h";

  systemd.services.pyboat = {
    description = "Pyboat game server";
    wantedBy = [ "multi-user.target" ];
    wants = [ "acme-pyboat.service" ];
    after = [
      "network.target"
      "acme-pyboat.service"
    ];
    unitConfig = {
      ConditionFileIsExecutable = "/var/lib/pyboat/server";
      # ACME creates self-signed placeholders before the first trusted issuance.
      ConditionPathExists = "/var/lib/acme/pyboat/acme-success";
    };
    serviceConfig = {
      User = "pyboat";
      Group = "pyboat";
      ExecStart = "/var/lib/pyboat/server 0.0.0.0:8765 /var/lib/acme/pyboat/fullchain.pem /var/lib/acme/pyboat/key.pem";
      ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
    };
  };

  system.stateVersion = "26.11";
}
