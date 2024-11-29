{ lib
, buildLinux
, fetchFromGitHub
, ... } @ args:
let
  src = fetchFromGitHub {
    owner = "esmil";
    repo = "linux";
    # Last git revision from the `riscv/d1-wip` branch:
    rev = "eb44174b12f99d320be704b45db6b994f6a014bd";
    sha256 = "sha256-zBIJR5JbrJniuuQaKMvbfExc+9PJ82VxvQkONtVEIC8=";
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
in buildLinux (args // {
  inherit src;
#  enableCommonConfig = false;
  defconfig = "hifive-premier-p550_defconfig";
#  config = ./config.nezha;
#  autoModules = false;
  structuredExtraConfig = with lib.kernel; {
    BCACHEFS_FS = lib.mkForce yes;
  };
  modDirVersion = "${modDirVersion}-eic7700";
  version = "${modDirVersion}-eic7700";
  extraMeta = {
    description = "A sort-of maintained linux tree for p550, with patches from smaeul and esmil";
    platforms = [ "riscv64-linux" ];
    hydraPlatforms = [ "" ];
  };
} // (args.argsOverride or { }))

