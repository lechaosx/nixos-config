{
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { nixpkgs, home-manager, ... }:
	let
		nixosModules = {
			base    = ./modules/base.nix;
			desktop = ./modules/desktop.nix;
			grub    = ./modules/grub.nix;
		};

		mkHost = name:
			nixpkgs.lib.nixosSystem {
				specialArgs = { customModules = nixosModules; };
				modules = [
					./hosts/${name}/configuration.nix
					home-manager.nixosModules.home-manager {
						home-manager.useGlobalPkgs = true;
						home-manager.useUserPackages = true;
						home-manager.users.dlabaja = import ./home-manager/dlabaja.nix;
					}
				];
			};
	in {
		nixosConfigurations = nixpkgs.lib.genAttrs [ "dlabaja-desktop" "dlabaja-asus" ] mkHost;

		inherit nixosModules;
	};
}
