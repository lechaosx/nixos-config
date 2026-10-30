{ pkgs, ... }:
{
  home.packages = [
    pkgs.gnomeExtensions.vitals
    pkgs.gnomeExtensions.run-or-raise
  ];

  programs = {
    ghostty = {
      enable = true;
      settings = {
        font-size = "8.8";
        shell-integration-features = "ssh-env,ssh-terminfo";
      };
    };
  };

  # Copilot key emits Super+Shift+F23
  xdg.configFile."run-or-raise/shortcuts.conf".text = ''
    <Super><Shift>F23:minimize-when-unfocused,xdg-terminal-exec,com.mitchellh.ghostty,
  '';

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      clock-show-seconds = true;
    };
    "org/gnome/desktop/input-sources" = {
      sources = [
        (pkgs.lib.gvariant.mkTuple [
          "xkb"
          "cz+coder"
        ])
      ];
      # cz+coder is only listed in evdev.extras.xml, which GNOME ignores otherwise
      show-all-sources = true;
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = pkgs.lib.gvariant.mkEmptyArray pkgs.lib.gvariant.type.string;
    };
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };
    "org/gnome/desktop/app-folders" = {
      folder-children = [ "" ];
    };
    "org/gnome/shell" = {
      app-picker-layout = [ "" ];
    };
  };
}
