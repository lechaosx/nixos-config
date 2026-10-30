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
        workstation = ./modules/workstation.nix;
        desktop = ./modules/desktop.nix;
        gaming = ./modules/gaming.nix;
        grub = ./modules/grub.nix;
        podman = ./modules/podman.nix;
      };

      homeManagerModules = {
        workstation = ./home-manager-modules/workstation.nix;
        claude-code = ./home-manager-modules/ai/claude-code.nix;
        codex = ./home-manager-modules/ai/codex.nix;
      };

      nixosConfigurations = {
        dlabaja-desktop = nixpkgs.lib.nixosSystem {
          modules = [
            home-manager.nixosModules.home-manager
            self.nixosModules.workstation
            self.nixosModules.desktop
            self.nixosModules.gaming
            self.nixosModules.grub
            self.nixosModules.podman
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.dlabaja.imports = [
                  self.homeManagerModules.workstation
                  self.homeManagerModules.codex
                  ./home-manager/dlabaja.nix
                ];
              };
            }
            ./hosts/dlabaja-desktop/configuration.nix
          ];
        };

        dlabaja-asus = nixpkgs.lib.nixosSystem {
          modules = [
            home-manager.nixosModules.home-manager
            self.nixosModules.workstation
            self.nixosModules.desktop
            self.nixosModules.gaming
            self.nixosModules.grub
            self.nixosModules.podman
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.dlabaja.imports = [
                  self.homeManagerModules.workstation
                  self.homeManagerModules.codex
                  ./home-manager/dlabaja.nix
                ];
              };
            }
            ./hosts/dlabaja-asus/configuration.nix
          ];
        };

        raspberrypi = nixpkgs.lib.nixosSystem {
          modules = [ ./hosts/raspberrypi/configuration.nix ];
        };
      };
    };
}
