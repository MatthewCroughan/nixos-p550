{ lib
, buildLinux
, gcc14Stdenv
, hexdump
, fetchFromGitHub
, ... } @ args:
let
  src = fetchFromGitHub {
    owner = "sifive";
    repo = "riscv-linux";
    # dev/kernel/hifive-premier-p550
    rev = "234cf73a25c0796b81675bcbca686df7cd98b992";
    sha256 = "sha256-YH34B0SAMng+M89a5sA/KSsJlFeY5ZHn/FR0aNHXuL0=";
  };
#  src = fetchFromGitHub {
#    owner = "sifive";
#    repo = "riscv-linux";
#    # rel/kernel/hifive-premier-p550
#    rev = "022315aa62e5160face9de04d895090794d088b2";
#    sha256 = "sha256-Usai8R18TwrKxPpcCxjrZNo/kLVjSEWcNT/xfw8SxYY=";
#  };
#  src = fetchFromGitHub {
#    owner = "rockos-riscv";
#    repo = "rockos-kernel";
#    # rel/kernel/hifive-premier-p550
#    rev = "f457de2129d5136a56128cf48e6d9ed040e8686c";
#    sha256 = "sha256-q/z1mED0Tc6ASAjHQ0rtczts4MU8QeReE89/4kLv7Ko=";
#  };
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
#  baseConfig = "defconfig";
#  DTB = true;
#  autoModules = true;
#  preferBuiltin = true;
#  target = "vmlinuz.efi";
#  installTarget = "zinstall";
#  enableCommonConfig = false;
#  defconfig = "eic7700_defconfig";
#  config = ./f;
#  autoModules = true;

  defconfig = "hifive-premier-p550_defconfig";
  structuredExtraConfig = with lib.kernel; {
#    EFI_ZBOOT = lib.mkForce yes;
#    KERNEL_ZSTD = lib.mkForce yes;

    SND_SOC_ES8328 = lib.mkForce no;
    SND_SOC_ES8328_I2C = lib.mkForce no;
    SND_SOC_ES8328_SPI = lib.mkForce no;
    ESWIN_MIPI_DSI = lib.mkForce yes;
    DRM_IMG_VOLCANIC = lib.mkForce yes;

#    USB_DWC3_GADGET = lib.mkForce yes;
#    USB_DWC3_HOST = lib.mkForce no;
#    USB_DWC3_DUAL_ROLE = lib.mkForce yes;
#    KERNEL_UNCOMPRESSED = lib.mkForce no;
#    EFI_STUB = lib.mkForce no;
#    BCMDHD = lib.mkForce no;
#    ESWIN_DSP = lib.mkForce no;
#    DRM_IMG = lib.mkForce yes;
#    ESWIN_MIPI_DSI = lib.mkForce no;
#    DRM_ESWIN = lib.mkForce yes;
#    DRM_LEGACY = lib.mkForce yes;
#    SND_SOC_ES8328 = lib.mkForce no;
#    SND_SOC_ES8328_SPI = lib.mkForce no;
#    SND_SOC_ES8328_I2C = lib.mkForce no;
#    SND_SOC_IMX_ES8328 = lib.mkForce no;

  };

  modDirVersion = "${modDirVersion}";
  version = "${modDirVersion}";
  extraMeta = {
    description = "A sort-of maintained linux tree for p550, with patches from esmil";
    platforms = [ "riscv64-linux" ];
    hydraPlatforms = [ "" ];
  };
} // (args.argsOverride or { }))).overrideAttrs (old: {
  patches = [
    ./fix-imagination-gpu-includes.patch
    ./fix-zboot.patch
  ];
  nativeBuildInputs = old.nativeBuildInputs ++ [
    hexdump
  ];
#  prePatch = ''
#    substituteInPlace arch/riscv/Makefile --replace-fail 'Image.gz' 'Image.zst'
#    substituteInPlace arch/riscv/boot/install.sh --replace-fail 'Image.gz' 'Image.zst'
#    cat arch/riscv/Makefile
#    cat arch/riscv/boot/install.sh
#  '';
#  preConfigure = ''
#    patchShebangs ./debian/scripts/misc/annotations
#    ./debian/scripts/misc/annotations -a riscv64 -e > .config
#    make oldconfig
#  '';
  NIX_CFLAGS_LINK = "--emit-relocs";
})

