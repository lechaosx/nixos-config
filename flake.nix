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
		mkHost = name:
			nixpkgs.lib.nixosSystem {
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
	};
}
