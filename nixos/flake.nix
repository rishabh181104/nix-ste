{
  description = "My NixOS configuration with Zen Browser and Google Chrome";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, zen-browser, ... }@inputs:  # Add @inputs here
  let
    system = "x86_64-linux"; # Adjust to "aarch64-linux" if on ARM
    pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
  in
  {
    nixosConfigurations.nix-ste = nixpkgs.lib.nixosSystem {  # Changed to "nix-ste" based on error
      inherit system;
      specialArgs = { inherit inputs; };  # Now inputs is defined
      modules = [
        ./configuration.nix
      ];
    };
  };
}
