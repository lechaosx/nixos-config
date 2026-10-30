{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    {
      nixosModules = {
        base = ./modules/base.nix;
        desktop = ./modules/desktop.nix;
        gaming = ./modules/gaming.nix;
        grub = ./modules/grub.nix;
        docker = ./modules/docker.nix;
        podman = ./modules/podman.nix;
      };

      homeManagerModules = {
        base = ./home-manager-modules/base.nix;
        claude-code = ./home-manager-modules/ai/claude-code.nix;
        codex = ./home-manager-modules/ai/codex.nix;
      };

      nixosConfigurations = {
        dlabaja-desktop = nixpkgs.lib.nixosSystem {
          specialArgs = { customModules = self.nixosModules; };
          modules = [
            ./hosts/dlabaja-desktop/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { customModules = self.homeManagerModules; };
                users.dlabaja = import ./home-manager/dlabaja.nix;
              };
            }
          ];
        };

        dlabaja-asus = nixpkgs.lib.nixosSystem {
          specialArgs = { customModules = self.nixosModules; };
          modules = [
            ./hosts/dlabaja-asus/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { customModules = self.homeManagerModules; };
                users.dlabaja = import ./home-manager/dlabaja.nix;
              };
            }
          ];
        };

        raspberrypi = nixpkgs.lib.nixosSystem {
          specialArgs = { customModules = self.nixosModules; };
          modules = [ ./hosts/raspberrypi/configuration.nix ];
        };
      };
    };
}
