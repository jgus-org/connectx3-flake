{
  description = "A devShell for managing legacy Mellanox ConnectX-3 hardware";

  inputs = {
    # We pin nixpkgs to a 23.05 release, last where mstflint still supported the CX3
    nixpkgs-legacy.url = "github:NixOS/nixpkgs/nixos-23.05";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs-legacy, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs-legacy = import nixpkgs-legacy { inherit system; };
      in
      {
        devShells.default = pkgs-legacy.mkShellNoCC {
          buildInputs = [
            pkgs-legacy.mstflint
            pkgs-legacy.pciutils
          ];

          shellHook = ''
            echo "--- Mellanox Legacy Management Shell ---"
            echo "Hardware: Dell R730xd | NIC: ConnectX-3"
            echo "Tools loaded: mstconfig, mstflint (v4.21.0-1)"
            echo "Tip: Use 'sudo mstconfig -d <PCI_ADDR> query' to start."
          '';
        };
      });
}
