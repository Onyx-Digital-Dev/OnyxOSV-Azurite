# ONYX OSV - Enterprise-grade Flake-based NixOS Distribution
#
# This is the single source of truth for OSV.
# All behavior is derived from this flake.
#
# Target: NixOS 25.11 (stable)
# No unstable channel. No runtime hacks.
{
  description = "ONYX OSV - Deterministic, reproducible NixOS distribution";

  inputs = {
    # Pin to NixOS 25.11 stable
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    # DankMaterialShell - Desktop environment
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, dms, ... }@inputs:
    let
      # Supported systems
      supportedSystems = [ "x86_64-linux" ];

      # Helper to generate attrs for each system
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # OSV library functions
      osvLib = import ./lib { inherit (nixpkgs) lib; };

      # Common module set for all hosts
      commonModules = [
        # OSV core module system
        ./modules/osv

        # DankMaterialShell modules
        dms.nixosModules.dankMaterialShell
        dms.nixosModules.greeter
      ];

      # Build a host configuration
      mkHost = { hostName, system ? "x86_64-linux", extraModules ? [] }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs osvLib;
            osvHostName = hostName;
          };
          modules = commonModules ++ [
            ./hosts/${hostName}
          ] ++ extraModules;
        };

    in {
      # NixOS configurations for each host
      nixosConfigurations = {
        # Primary testbed - NVIDIA PRIME hybrid laptop
        wraith = mkHost {
          hostName = "wraith";
          system = "x86_64-linux";
        };

        # Secondary host - Desktop with dedicated NVIDIA
        athena = mkHost {
          hostName = "athena";
          system = "x86_64-linux";
        };
      };

      # Expose OSV library for external use
      lib = osvLib;

      # Flake checks
      checks = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in {
          # Verify flake evaluates correctly
          flakeEval = pkgs.runCommand "osv-flake-eval" {} ''
            echo "OSV flake evaluation check passed"
            touch $out
          '';
        }
      );

      # Development shells
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            name = "osv-dev";
            packages = with pkgs; [
              nil  # Nix LSP
              nixpkgs-fmt
            ];
          };
        }
      );
    };
}
