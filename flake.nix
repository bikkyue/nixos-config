{
  description = "Dotfiles managed by Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lazyvim = {
      url = "github:pfassina/lazyvim-nix";
    };
  };

  outputs = { nixpkgs, home-manager, lazyvim, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations."ubuntu" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ 
           lazyvim.homeManagerModules.default
           ./home.nix 
        ];
      };
    };
}

