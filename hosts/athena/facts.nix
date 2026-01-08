# Athena Host Facts
#
# ThinkPad T580 - Intel integrated graphics laptop
{ ... }:

{
  osv.facts = {
    # Intel integrated graphics only
    gpu = "intel";

    # Laptop with built-in display
    hasInternalDisplay = true;

    # Is a laptop
    isLaptop = true;

    # Has Bluetooth
    hasBluetooth = true;

    # WiFi and ethernet
    primaryNetwork = "both";
  };
}
