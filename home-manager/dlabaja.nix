{
  pkgs,
  customModules,
  ...
}:
{
  imports = [
    customModules.base
    customModules.codex
  ];

  home.packages = with pkgs; [
    discord
    aseprite
    lua
  ];

  programs.npm = {
    enable = true;
    settings.prefix = "\${HOME}/.local";
  };

  programs.git.settings.user = {
    name = "Drahomír Dlabaja";
    email = "lechaosx@gmail.com";
  };

  home.stateVersion = "24.11";
}
