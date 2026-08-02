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
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      claude-code-nix,
      ...
    }:
    let
      username = "bikkyue";
      mkHome =
        system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit inputs username; };
          modules = [
            ./home.nix
            {
              home.packages = [
                claude-code-nix.packages.${system}.claude-code
              ];
            }
          ];
        };
    in
    {
      nixosConfigurations.Shironere = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/Shironere/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs username; };
              users.${username} = {
                imports = [ ./home.nix ];
                home.packages = [
                  claude-code-nix.packages.x86_64-linux.claude-code
                ];
              };
            };
          }
        ];
      };

      homeConfigurations = {
        "bikkyue@macos" = mkHome "aarch64-darwin";
        "bikkyue@linux" = mkHome "x86_64-linux";
      };
    };
}
