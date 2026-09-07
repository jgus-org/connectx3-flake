# connectx3-flake

A Nix `devShell` for managing legacy Mellanox ConnectX-3 hardware on a Dell R730xd.

It pins `nixpkgs` to the 23.05 release — the last where `mstflint` still
supported the CX3 — and provides `mstconfig`, `mstflint`, and `pciutils`.

## Launch

Run the shell directly from GitHub (requires Nix with flakes enabled):

```sh
nix develop github:jgus-org/connectx3-flake
```

## Common commands

Find your card's PCI address:

```sh
lspci | grep Mellanox
```

Substitute the address (e.g. `83:00.0`) into the commands below.

### Query firmware info

```sh
sudo mstflint -d 83:00.0 query full
```

### Flash firmware

```sh
wget https://www.mellanox.com/downloads/firmware/fw-ConnectX3-rel-2_42_5000-MCX354A-FCB_A2-A5-FlexBoot-3.4.752.bin.zip
unzip fw-ConnectX3-rel-2_42_5000-MCX354A-FCB_A2-A5-FlexBoot-3.4.752.bin.zip
sudo mstflint -d 83:00.0 -i fw-ConnectX3-rel-2_42_5000-MCX354A-FCB_A2-A5-FlexBoot-3.4.752.bin burn
```

### Set both ports to Ethernet mode

```sh
sudo mstconfig -d 83:00.0 set LINK_TYPE_P1=2 LINK_TYPE_P2=2
```

### Check whether UEFI options appeared

```sh
sudo mstconfig -d 83:00.0 query | grep UEFI
```

If `UEFI_HII_EN` (or similar) appears, enable it:

```sh
sudo mstconfig -d 83:00.0 set UEFI_HII_EN=1
```
