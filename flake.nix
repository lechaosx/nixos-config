{
	description = "NixOS configuration";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
		home-manager = {
			url = "github:nix-community/home-manager/release-24.11";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { nixpkgs, home-manager, ... }: {
		nixosConfigurations = {
			dlabaja = nixpkgs.lib.nixosSystem {
				modules = [
					./nixos/configuration.nix
					home-manager.nixosModules.home-manager {
						home-manager.users.dlabaja = import ./home-manager/dlabaja.nix;
					}
				];
			};
		};
	};
}
