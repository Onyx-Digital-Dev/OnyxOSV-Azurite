# Belial Host Facts
#
# Dell R740XD Server Workstation - Dual Xeon Gold 6240, RTX 5000
{ ... }:

{
  osv.facts = {
    # NVIDIA Quadro RTX 5000 (dedicated)
    gpu = "nvidia";

    # Server chassis - external displays only
    hasInternalDisplay = false;

    # Not a laptop
    isLaptop = false;

    # No Bluetooth hardware
    hasBluetooth = false;

    # Ethernet only (no WiFi)
    primaryNetwork = "ethernet";
  };
}
