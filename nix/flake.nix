{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let pkgs = nixpkgs.legacyPackages.${system}.pkgsCross.riscv64; in
        {
          packages.uboot = (pkgs.buildUBoot {
            filesToInstall = [
              "bootinfo_emmc.bin"
              "bootinfo_sd.bin"
              "bootinfo_spinor.bin"
              "FSBL.bin"
              "u-boot-env-default.txt"
              "u-boot-opensbi.itb"
            ];
            defconfig = "x1_defconfig";
            version = "v2022.10-ky";
            patches = [];
            postPatch = ''
              patchShebangs ./opensbi/scripts/
              substituteInPlace ./opensbi/Makefile --replace "mkimage" "/build/source/tools/mkimage"
            '';
            src = pkgs.fetchFromGitHub {
              owner = "orangepi-xunlong";
              repo = "u-boot-orangepi";
              rev = "v2022.10-ky";
              hash = "sha256-tgVas1g5fVT1HCyebS5SUmQIKyxry99EciuwZ/RS3x8=";

            };
          }).overrideAttrs(attrs: rec {
            # nativeBuildInputs = attrs.nativeBuildInputs ++ [ nixpkgs.legacyPackages.${system}.breakpointHook ];
          });
        }
  );
}
