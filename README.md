# nix-fex-rootfs

x86_64 rootfs based on Fedora 44 and NixOS module for [FEX-Emu](https://fex-emu.com)

## Use from NixOS

```nix
{
  inputs.nix-fex-rootfs.url = "github:yannhodiesne/nix-fex-rootfs";
  # pin a weekly release for an immutable rootfs:
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

It then registers the FEX binfmt handlers, mounts the erofs read-only at `/run/fex/rootfs`, and sets `FEX_ROOTFS`.

Available options: `services.fex.enable`, `services.fex.rootfsPath`, `services.fex.package`, `services.fex.image`.

## Release model

CI runs `./build.sh` every Monday.

## Build locally

Needs an x86_64 host or VM:

```sh
./build.sh
nix flake check
```

## Customize

Edit the `dnf install` lines in `Containerfile`, then re-run `./build.sh`.
