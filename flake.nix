{
  description = "A devShell for managing legacy Mellanox ConnectX-3 hardware";

  inputs = {
    flake-lib.url = "github:jgus-org/flake-lib/v1";
    # The shell's payload stays on a 23.05 release, last where mstflint still supported the CX3.
    nixpkgs-legacy.url = "github:NixOS/nixpkgs/nixos-23.05";
  };

  outputs =
    {
      self,
      flake-lib,
      nixpkgs-legacy,
    }:
    flake-lib.lib.eachDefaultLinuxSystem (
      system:
      let
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
