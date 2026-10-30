{ pkgs, lib, ... }:
let
  # alsa-lib resolves iec958:CARD=x to device 0 (the analog endpoint) for any USB card
  # missing from its iec958_device quirk table, so PipeWire's profile probe succeeds and
  # every USB headset gains a phantom S/PDIF output. Invert the fallback to a device
  # number that cannot open, matching what upstream already does for iec958_2.
  # https://github.com/alsa-project/alsa-lib/issues/292
  alsaConfigDir = pkgs.runCommand "alsa-config-no-phantom-iec958" { } ''
    cp -r --no-preserve=mode ${pkgs.alsa-lib}/share/alsa $out

    matches=$(grep -cE '^[[:space:]]+default 0$' $out/cards/USB-Audio.conf)
    if [ "$matches" != 1 ]; then
    	echo "expected exactly one iec958 fallback, found $matches" >&2
    	exit 1
    fi

    sed -i -E 's/^([[:space:]]+)default 0$/\1default 999/' $out/cards/USB-Audio.conf
  '';
in
{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    optimise.automatic = true;
  };

  # nix.gc can only expire generations by age; nh expires by count.
  programs.nh.clean = {
    enable = true;
    extraArgs = "--keep 3 --keep-one";
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
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.fish;
  };

  programs = {
    nano.enable = false;

    # Also needed at system level: registers /etc/shells and the vendor
    # completion paths that system packages install into
    fish.enable = true;

    # The editor for root and processes outside the user's home-manager
    # profile: EDITOR, plus `vi` for tools that fall back to it without EDITOR
    neovim = {
      enable = true;
      viAlias = true;
      defaultEditor = true;
    };

    firefox.enable = true;

    nix-ld.enable = true;

    dconf.profiles.gdm.databases = [
      {
        settings."org/gnome/desktop/interface".scaling-factor = lib.gvariant.mkUint32 1;
      }
    ];
  };

  services = {
    envfs.enable = true;
    swapspace.enable = true;

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

  xdg.terminal-exec = {
    enable = true;
    settings.GNOME = [ "com.mitchellh.ghostty.desktop" ];
  };

  # WirePlumber probes card profiles as a user unit, before any shell profile is
  # sourced, so the variable has to come from the user manager itself.
  systemd.user.settings.Manager.DefaultEnvironment = "ALSA_CONFIG_DIR=${alsaConfigDir}";

  environment.gnome.excludePackages = [
    pkgs.showtime
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
    pkgs.gnome-console
  ];

  zramSwap = {
    enable = true;
    priority = 100;
  };

  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    nerd-fonts.adwaita-mono
  ];

  fonts.fontconfig.localConf = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
    <fontconfig>
      <alias>
        <family>Adwaita Mono</family>
        <prefer>
          <family>AdwaitaMono Nerd Font Mono</family>
        </prefer>
      </alias>
    </fontconfig>
    	'';
}
