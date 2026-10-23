{
  description = "A devShell for managing legacy Mellanox ConnectX-3 hardware";

  inputs = {
    flake-lib.url = "github:jgus-org/flake-lib/v1";
    # Tree tooling (the formatter, and flake-lib's host lists) tracks the fleet's current nixpkgs.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    # The shell's payload stays on a 23.05 release, last where mstflint still supported the CX3.
    nixpkgs-legacy.url = "github:NixOS/nixpkgs/nixos-23.05";
  };

  outputs =
    {
      self,
      flake-lib,
      nixpkgs,
      nixpkgs-legacy,
    }:
    flake-lib.lib.eachDefaultLinuxSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        pkgs-legacy = import nixpkgs-legacy { inherit system; };

        orgFormatting = flake-lib.lib.mkFormatting {
          inherit self system;
        };
      in
      {
        checks.formatting = orgFormatting.check;
        devShells.default = pkgs-legacy.mkShellNoCC {
          buildInputs = [
            pkgs-legacy.mstflint
            pkgs-legacy.pciutils
          ];

          shellHook = ''
            echo "--- Mellanox Legacy Management Shell ---"
            echo "Hardware: Dell R730xd | NIC: ConnectX-3"
            echo "Tools loaded: mstconfig, mstflint (v4.17.0-1)"
            echo "Tip: Use 'sudo mstconfig -d <PCI_ADDR> query' to start."
          '';
        };
        formatter = orgFormatting.formatter;
      }
    );
}
