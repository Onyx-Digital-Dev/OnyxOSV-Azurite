# Saipan Host Facts
#
# STATIC hardware facts for Saipan.
# Lenovo ThinkCentre M710q - i5-6500T, Intel HD 530, 16GB RAM
#
# This file is DATA ONLY - no logic.
{ ... }:

{
  osv.facts = {
    # Intel HD Graphics 530 (integrated)
    gpu = "intel";

    # Desktop - external display only (MSI MAG401QR)
    hasInternalDisplay = false;

    # ThinkCentre M710q mini desktop
    isLaptop = false;

    # Has Bluetooth hardware
    hasBluetooth = true;

    # Ethernet (enp0s31f6)
    primaryNetwork = "ethernet";
  };
}
