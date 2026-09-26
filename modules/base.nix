{ pkgs, ... }:
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
      "docker"
    ];
    shell = pkgs.fish;
  };

  programs = {
    nano.enable = false;

    # Also needed at system level: registers /etc/shells and the vendor
    # completion paths that system packages install into
    fish.enable = true;
    neovim = {
      enable = true;
      vimAlias = true;
      viAlias = true;
      defaultEditor = true;
    };

    firefox.enable = true;

    nix-ld.enable = true;
  };

  services = {
    envfs.enable = true;
    swapspace.enable = true;
  };

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
