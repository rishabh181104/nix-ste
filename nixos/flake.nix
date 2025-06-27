{

	description = "My first flake";

	inputs = {
		nixpkgs.url = "nixpkgs/nixos-unstable";
	};

	outputs = { self, nixpkgs, ...}:
	let
		lib = nixpkgs.lib;
	in {
		nixosConfigurations = {
			nix-ste = lib.nixosSystem {
			system = "x86_64-linux";
			modules = [ ./configuration.nix ];
			};
		};
	};

}
