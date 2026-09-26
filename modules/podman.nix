{ lib, pkgs, ... }:
{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  environment.systemPackages = with pkgs; [
    docker-compose
    podman-compose
  ];

  # `podman compose` runs the first provider that exists here; override a single
  # invocation with PODMAN_COMPOSE_PROVIDER.
  virtualisation.containers.containersConf.settings.engine.compose_providers = [
    (lib.getExe pkgs.docker-compose)
    (lib.getExe pkgs.podman-compose)
  ];
}
