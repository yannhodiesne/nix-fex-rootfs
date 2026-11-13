{
  description = "Fedora 44 x86_64 rootfs for FEX-Emu, plus a NixOS module";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "aarch64-linux"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));

      mkRootfs =
        pkgs:
        let
          image = pkgs.fetchurl {
            url = "https://github.com/yannhodiesne/nix-fex-rootfs/releases/download/2026.11.13/fex-rootfs.erofs";
            hash = "sha256-yrre6DTdFGfibpW/okztIRBcWYjmAK3CeeTM8fX9EDA=";
          };
        in
        pkgs.runCommand "fex-rootfs-attested.erofs" { } ''
          echo "$(nix hash convert --to sri --hash-algo sha256 "$(nix hash path ${image})")" > $out.sha256
          cp ${image} $out
        '';
    in
    {
      packages = forAllSystems (pkgs: {
        fex-rootfs = mkRootfs pkgs;
        default = mkRootfs pkgs;
      });

      nixosModules.default =
        { lib, pkgs, utils, config, ... }@args:
        import ./module.nix (
          {
            inherit
              lib
              pkgs
              utils
              config
              self
              ;
          }
          // removeAttrs args [ "self" ]
        );
      
      nixosModules.fex = self.nixosModules.default;
    };
}
