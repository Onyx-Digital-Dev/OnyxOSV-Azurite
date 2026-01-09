# Shogun Hardware Configuration
#
# ThinkPad T580 - Intel i7, 32GB RAM, 1TB NVMe
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "uas" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/a4b0b6f0-eb07-460e-bbae-f27aad8bc97e";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/C296-9FC0";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/466607bf-cc5b-413b-809c-aba7e004183c"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
