{
  description = "My NixOS configuration with Zen Browser, Google Chrome, and Secure Boot via Lanzaboote";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, zen-browser, lanzaboote, home-manager, ... }@inputs:
    let
    lib = nixpkgs.lib;
  system = "x86_64-linux";
# Optional: Only keep this if needed by other parts of your configuration
  pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
  in
  {
    nixosConfigurations.nix-ste = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
          lanzaboote.nixosModules.lanzaboote
          ({
           boot.loader.systemd-boot.enable = lib.mkForce false;
           boot.lanzaboote = {
           enable = true;
           pkiBundle = "/var/lib/sbctl";
           };
           })
      ];
    };
    homeConfigurations = {
      ste = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
      };
    };
  };
}
