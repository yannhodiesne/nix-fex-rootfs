# NixOS module: FEX binfmt registration + read-only mount of the rootfs
{ lib, pkgs, utils, config, self, ... }:
let
  cfg = config.services.fex;
in
{
  options.services.fex = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable FEX-Emu x86_64/i386 binfmt translation";
    };
    rootfsPath = lib.mkOption {
      type = lib.types.str;
      default = "/run/fex/rootfs";
      description = "Mount point for the x86_64 rootfs; also set as FEX_ROOTFS";
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.fex;
      description = "FEX-Emu package providing the binfmt interpreter";
    };
    image = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${pkgs.stdenv.hostPlatform.system}.fex-rootfs;
      description = "EROFS rootfs image to mount at services.fex.rootfsPath";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.hostPlatform.isAarch64;
        message = "nix-fex-rootfs: FEX translates x86 binaries on aarch64 hosts only";
      }
    ];

    nixpkgs.config.allowUnsupportedSystem = true;

    environment.systemPackages = [ cfg.package ];

    boot.binfmt.registrations =
      lib.mapAttrs
        (_: magic: {
          inherit (magic) magicOrExtension mask;
          interpreter = "${cfg.package}/bin/FEX";
          preserveArgvZero = true;
          openBinary = true;
          matchCredentials = true;
          fixBinary = true;
          wrapInterpreterInShell = false;
        })
        {
          FEX-x86_64 = utils.binfmtMagics.x86_64-linux;
          FEX-i386 = utils.binfmtMagics.i386-linux;
        };

    fileSystems.${cfg.rootfsPath} = {
      device = "${cfg.image}";
      fsType = "erofs";
      options = [
        "loop"
        "ro"
        "nosuid"
        "nodev"
        "nofail"
      ];
    };

    environment.sessionVariables.FEX_ROOTFS = cfg.rootfsPath;
  };
}
