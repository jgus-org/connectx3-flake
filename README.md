# connectx3-flake

A Nix flake that provides a development shell for programming legacy Mellanox ConnectX-3 host channel adapters, built on [mstflint](https://github.com/Mellanox/mstflint) — the open-source version of Mellanox Firmware Tools — and [pciutils](https://github.com/pciutils/pciutils).

## Outputs

- `devShells.<system>.default` — an interactive shell carrying the `mstflint` tools (`mstflint`, `mstconfig`) and `lspci`.

There are no packages, overlays, or apps: the shell is the flake's only consumable output (`formatter` and `checks.formatting` are maintenance outputs). `<system>` covers `x86_64-linux` and `aarch64-linux` only. `mstflint` needs the Linux kernel and the card in the host it runs in, so there is nothing to build for macOS.

## Consuming it

Open the shell directly:

```bash
nix develop github:jgus-org/connectx3-flake
```

Or take it from a flake input as `inputs.connectx3.devShells.${system}.default`.

Following this flake's `nixpkgs` into your own does not change the tools you get — they come from its separate `nixpkgs-legacy` input, which exists precisely because the shell's payload is frozen (see below). Following `nixpkgs-legacy` would replace that frozen toolset with your own nixpkgs' copy, which is the one thing this flake exists to avoid.

## Tool vintage

The shell's tools come from the nixpkgs 23.05 release: `mstflint` 4.17.0-1 and `pciutils` 3.9.0. That pin is the point of this flake — newer `mstflint` releases dropped ConnectX-3 — so the tools here do not track newer tooling. Expect 4.17-era behaviour and option names.

## Runtime requirements

Run it on the machine the card is installed in, as root: these tools read and write the adapter's flash over the host's PCI bus, and there is no remote mode. `lspci` names the card, and its PCI address is what `-d` takes on every other command:

```bash
lspci | grep Mellanox
```

Substitute the address (e.g. `83:00.0`) below. Where `sudo` reports `command not found`, it is because the tools live in the Nix store and `sudo`'s path does not carry them — invoke them by resolved path, as in `sudo $(command -v mstconfig)`.

## Common commands

Query firmware info:

```bash
sudo mstflint -d 83:00.0 query full
```

Flash firmware. The image for this card is the `fw-ConnectX3-rel-2_42_5000-MCX354A-FCB_A2-A5-FlexBoot-3.4.752.bin` release, unzipped from the vendor's downloadable archive:

```bash
sudo mstflint -d 83:00.0 -i fw-ConnectX3-rel-2_42_5000-MCX354A-FCB_A2-A5-FlexBoot-3.4.752.bin burn
```

Set both ports to Ethernet mode:

```bash
sudo mstconfig -d 83:00.0 set LINK_TYPE_P1=2 LINK_TYPE_P2=2
```

UEFI boot options for the card only appear once its UEFI option is enabled. Check first:

```bash
sudo mstconfig -d 83:00.0 query | grep UEFI
```

If `UEFI_HII_EN` (or a similar `UEFI_*` flag) appears, enable it:

```bash
sudo mstconfig -d 83:00.0 set UEFI_HII_EN=1
```

Both `set` commands write the card's non-volatile configuration, so query again after each one to confirm the write took.

See [LICENSE.md](LICENSE.md) for licensing and copyright.
