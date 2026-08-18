{
  description = "NixOS and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    omp = {
      url = "github:can1357/oh-my-pi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    apple-silicon-support = {
      url = "github:nix-community/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      apple-silicon-support,
      ...
    }:
    let
      username = "bikkyue";
      mkHome =
        system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit inputs username; };
          modules = [ ./home.nix ];
        };
    in
    {
      nixosConfigurations.Shironere = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nixos/Shironere/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs username; };
              users.${username} = import ./home.nix;
            };
          }
        ];
      };

      nixosConfigurations.Atarayo = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./nixos/Atarayo/configuration.nix
          apple-silicon-support.nixosModules.apple-silicon-support
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs username; };
              users.${username} = import ./home.nix;
            };
          }
        ];
      };

      homeConfigurations.${username} = mkHome builtins.currentSystem;
    };
}
