{ pkgs, lib, ... }:
{
  hardware.deviceTree.name = "eswin/eic7700-hifive-premier-p550.dtb";
  hardware.deviceTree.enable = true;
  boot.kernelPatches = [
    {
      name = "config-zboot-zstd";
      patch = null;
      extraStructuredConfig = {
#        KERNEL_UNCOMPRESSED = lib.mkForce lib.kernel.no;
        EFI_ZBOOT = lib.mkForce lib.kernel.yes;
#        KERNEL_GZIP = lib.mkForce lib.kernel.yes;
        KERNEL_ZSTD = lib.mkForce lib.kernel.yes;
      };
    }
  ];

  nixpkgs.buildPlatform = lib.systems.examples.gnu64;
  nixpkgs.hostPlatform = lib.recursiveUpdate (lib.systems.elaborate lib.systems.examples.riscv64) {
    linux-kernel.target = "vmlinuz.efi";
    linux-kernel.installTarget = "zinstall";
  };

#  nixpkgs.hostPlatform = lib.recursiveUpdate (lib.systems.elaborate "riscv64-linux") {
#    system = "riscv64-linux";
#    linux-kernel = {
#      baseConfig = "hifive-premier-p550_defconfig";
##      DTB = true;
##      autoModules = true;
##      preferBuiltin = true;
#      target = "vmlinuz.efi";
#      installTarget = "zinstall";
#    };
#  };

#  nixpkgs.crossSystem = {
#    system = "riscv64-linux";
#    linux-kernel = {
#      name = "riscv64-multiplatform";
#      baseConfig = "defconfig";
#      DTB = true;
#      autoModules = true;
#      preferBuiltin = true;
#      target = "vmlinuz.efi";
#      installTarget = "zinstall";
#    };
#  };

  boot.loader = {
    systemd-boot.enable = true;
  };

  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ./kernel.nix { });
  boot.initrd.includeDefaultModules = false;
  boot.initrd.availableKernelModules = lib.mkForce [
    "ext2"
    "ext4"
    "nvme"
    "sd_mod"
    "sr_mod"
    "xhci_pci"
    "uas"
  ];

  boot.kernelParams = [
    "rootwait"
    "earlycon=sbi"
    # "console=ttyS0,115200"
  ];
}
