{ pkgs, lib, ... }:
{
  hardware.deviceTree.name = "eswin/eic7700-hifive-premier-p550.dtb";
  boot.kernelPatches = [
    {
      name = "config-zboot-zstd";
      patch = null;
      extraStructuredConfig = {
        EFI_ZBOOT = lib.kernel.yes;
        KERNEL_ZSTD = lib.kernel.yes;
      };
    }
  ];
  nixpkgs.crossSystem = {
    system = "riscv64-linux";
    linux-kernel = {
      name = "riscv64-multiplatform";
      baseConfig = "defconfig";
      DTB = true;
      autoModules = true;
      preferBuiltin = true;
      target = "vmlinuz.efi";
      installTarget = "zinstall";
    };
  };
  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ./kernel.nix { });
  #  boot.initrd.includeDefaultModules = false;
  boot.initrd.availableKernelModules = lib.mkForce [
    "ext2"
    "ext4"
    "ahci"
    "nvme"
    "sd_mod"
    "sr_mod"
    "mmc_block"
    "uhci_hcd"
    "ehci_hcd"
    "ehci_pci"
    "ohci_hcd"
    "ohci_pci"
    "xhci_hcd"
    "xhci_pci"
    "usbhid"
    "hid_generic"
    "hid_lenovo"
    "hid_apple"
    "hid_roccat"
    "hid_logitech_hidpp"
    "hid_logitech_dj"
    "hid_microsoft"
    "hid_cherry"
    "hid_corsair"
  ];

  boot.kernelParams = [
    "rootwait"
    "earlycon=sbi"
    # "console=ttyS0,115200"
  ];
}
