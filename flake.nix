{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    apple-silicon-support = {
      url = "github:nix-community/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      apple-silicon-support,
      ...
    }:
    let
      mkHost =
        {
          name,
          system,
          extraModules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./hosts/${name}/configuration.nix ] ++ extraModules;
        };
    in
    {
      nixosConfigurations.Shironere = mkHost {
        name = "Shironere";
        system = "x86_64-linux";
      };

      nixosConfigurations.Atarayo = mkHost {
        name = "Atarayo";
        system = "aarch64-linux";
        extraModules = [ apple-silicon-support.nixosModules.apple-silicon-support ];
      };
    };
}
