{ lib
, buildLinux
, fetchFromGitHub
, ... } @ args:
let
  src = fetchFromGitHub {
    owner = "sifive";
    repo = "riscv-linux";
    # rel/kernel/hifive-premier-p550
    rev = "022315aa62e5160face9de04d895090794d088b2";
    sha256 = "sha256-Usai8R18TwrKxPpcCxjrZNo/kLVjSEWcNT/xfw8SxYY=";
  };
  kernelVersion = rec {
    # Fully constructed string, example: "5.10.0-rc5".
    string = "${version + "." + patchlevel + "." + sublevel + (lib.optionalString (extraversion != "") extraversion)}";
    file = "${src}/Makefile";
    version = toString (builtins.match ".+VERSION = ([0-9]+).+" (builtins.readFile file));
    patchlevel = toString (builtins.match ".+PATCHLEVEL = ([0-9]+).+" (builtins.readFile file));
    sublevel = toString (builtins.match ".+SUBLEVEL = ([0-9]+).+" (builtins.readFile file));
    # rc, next, etc.
    extraversion = toString (builtins.match ".+EXTRAVERSION = ([a-z0-9-]+).+" (builtins.readFile file));
  };
  modDirVersion = "${kernelVersion.string}";
in (buildLinux (args // {
  inherit src;
  enableCommonConfig = false;
  defconfig = "hifive-premier-p550_defconfig";
#  config = ./config.nezha;
  autoModules = false;
  structuredExtraConfig = with lib.kernel; {
#    BCACHEFS_FS = lib.mkForce yes;
#    DRM_IMG_VOLCANIC = lib.mkForce yes;
  };
  modDirVersion = "${modDirVersion}";
  version = "${modDirVersion}";
  extraMeta = {
    description = "A sort-of maintained linux tree for p550, with patches from esmil";
    platforms = [ "riscv64-linux" ];
    hydraPlatforms = [ "" ];
  };
} // (args.argsOverride or { }))).overrideAttrs {
#  preConfigure = ''
#    patchShebangs ./debian/scripts/misc/annotations
#    ./debian/scripts/misc/annotations -a riscv64 -e > .config
#    make oldconfig
#  '';
}

