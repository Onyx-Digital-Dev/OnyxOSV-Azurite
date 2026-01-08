# Warthog Host Facts
#
# Dell Latitude 5400 - Intel integrated graphics laptop
{ ... }:

{
  osv.facts = {
    # Intel integrated graphics
    gpu = "intel";

    # Laptop with internal display
    hasInternalDisplay = true;

    # Laptop form factor
    isLaptop = true;

    # Bluetooth enabled
    hasBluetooth = true;

    # WiFi and Ethernet
    primaryNetwork = "both";
  };
}
