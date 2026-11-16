# nix-fex-rootfs

Weekly x86_64 rootfs release with up-to-date packages based on Fedora 44, plus a NixOS module for [FEX-Emu](https://fex-emu.com).

The rootfs follows the official guide at [Setting up RootFS](https://wiki.fex-emu.com/index.php/Development:Setting_up_RootFS) and mirrors the official rootfs packages list.

## Why?

Because despite the FEX team's amazing work all-around, it bothers me a lot to use 3-month-old packages without the newest bells and whistles (understand: security fixes and performance improvements). And I wanted to see how hard it is to create a rootfs myself!

## Use from any distribution

You can download the latest rootfs from the [releases](https://github.com/yannhodiesne/nix-fex-rootfs/releases/latest) and use it on the distribution of your choice.

## Use from NixOS

This module sets up a binfmt handler to allow your kernel to run x86-64 programs and games without needing to call FEX directly. It's as close as you can get to a Rosetta-like experience!

```nix
{
  inputs.nix-fex-rootfs.url = "github:yannhodiesne/nix-fex-rootfs";
  # or pin a weekly release for an immutable rootfs:
  # inputs.nix-fex-rootfs.url = "github:yannhodiesne/nix-fex-rootfs/2026.11.17";

  outputs = { inputs, ... }: {
    nixosConfigurations.host = nixpkgs.lib.nixosSystem {
      modules = [ inputs.nix-fex-rootfs.nixosModules.default ];
    };
  };
}
```

The module is off by default; enable it in your configuration:

```nix
services.fex.enable = true;
```

It then registers the FEX binfmt handlers, mounts the EROFS image read-only at `/run/fex/rootfs`, and sets `FEX_ROOTFS`.

Available options: `services.fex.enable`, `services.fex.rootfsPath`, `services.fex.package`, `services.fex.tuneArch`, `services.fex.image`, `services.fex.server.enable`.

### Tuning FEX for your CPU

The official install script picks a different FEX package per CPU (armv8.0/8.2/8.4) whereas nixpkgs ships a single generic build. Set `tuneArch` to compile FEX's host code for a specific ARM architecture, like the official packages do:

```nix
{
  services.fex.enable = true;
  services.fex.tuneArch = "armv8.4-a"; # Adapt to the target CPU
}
```

## Release model

CI runs `./build.sh` every Monday from the main branch.

## Build locally

Needs an x86_64 host or VM:

```sh
./build.sh
```

## Customize

Edit the `dnf install` lines in `Containerfile`, then re-run `./build.sh`.
