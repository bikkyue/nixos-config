{
  description = "Dotfiles managed by Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code-nix = {
        url = "github:sadjow/claude-code-nix";
    };
  };

  outputs = { nixpkgs, home-manager, claude-code-nix, ... }:
    let
      system = builtins.currentSystem;
      pkgs = nixpkgs.legacyPackages.${system};
      user = builtins.getEnv "USER";
    in {
      homeConfigurations.${user} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
           ./home.nix
           {
              home.packages = [
                claude-code-nix.packages.${system}.claude-code 
              ];
            }
        ];
        extraSpecialArgs = { username = user; };
      };
    };
}

