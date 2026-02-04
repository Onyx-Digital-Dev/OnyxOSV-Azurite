# Saipan Host Facts
#
# STATIC hardware facts for Saipan.
# Derived from hardware inspection, not runtime probing.
#
# This file is DATA ONLY - no logic.
# TODO: Update all values to match actual hardware.
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
