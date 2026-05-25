# Flake entrypoint: declares inputs (nixpkgs unstable, home-manager master)
# and exposes one Home Manager configuration per host under homeConfigurations.
{
  description = "MH4GF dotfiles managed by Home Manager (standalone)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }: {
    homeConfigurations.mh4gf-mac = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      modules = [ ./hosts/mh4gf-mac.nix ];
    };
  };
}
