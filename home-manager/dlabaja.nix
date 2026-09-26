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
    transmission_4-qt
    aseprite
    lua
  ];

  programs.git.settings.user = {
    name = "Drahomír Dlabaja";
    email = "lechaosx@gmail.com";
  };

  home.stateVersion = "24.11";
}
