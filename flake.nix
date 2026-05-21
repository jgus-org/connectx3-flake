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

  # Flash:
  # wget https://www.mellanox.com/downloads/firmware/fw-ConnectX3-rel-2_42_5000-MCX354A-FCB_A2-A5-FlexBoot-3.4.752.bin.zip
  # sudo mstflint -d 83:00.0 -i fw-ConnectX3-rel-2_42_5000-MCX354A-FCB_A2-A5-FlexBoot-3.4.752.bin burn

  # Info:
  # sudo mstflint -d 83:00.0 query full

  # Set Ethernet mode:
  # sudo mstconfig -d 83:00.0 set LINK_TYPE_P1=2 LINK_TYPE_P2=2

  # Check if UEFI options appeared
  # sudo mstconfig -d 83:00.0 query | grep UEFI

  # If UEFI_HII_EN or similar appears, set it to true
  # sudo mstconfig -d 83:00.0 set UEFI_HII_EN=1
}
