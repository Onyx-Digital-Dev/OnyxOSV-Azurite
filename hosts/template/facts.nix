# Template Host Facts
#
# Copy this file as a starting point for new hosts.
# Update all values to match your hardware.
{ ... }:

{
  osv.facts = {
    # GPU type: "intel" | "amd" | "nvidia" | "hybrid"
    gpu = "intel";

    # Does this machine have a built-in display (laptop)?
    hasInternalDisplay = false;

    # Is this a laptop/portable device?
    isLaptop = false;

    # Does this machine have Bluetooth hardware?
    hasBluetooth = true;

    # Primary network type: "ethernet" | "wifi" | "both"
    primaryNetwork = "ethernet";
  };
}
