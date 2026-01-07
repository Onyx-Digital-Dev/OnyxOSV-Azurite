# Athena Host Facts
#
# STATIC hardware facts for Athena.
# Derived from hardware inspection, not runtime probing.
#
# This file is DATA ONLY - no logic.
#
# NOTE: Update these values to match actual Athena hardware
# before deploying. These are placeholder values.
{ ... }:

{
  osv.facts = {
    # Desktop with dedicated NVIDIA GPU
    gpu = "nvidia";

    # No built-in display (desktop)
    hasInternalDisplay = false;

    # Not a laptop
    isLaptop = false;

    # Has Bluetooth hardware
    hasBluetooth = true;

    # Ethernet only (desktop)
    primaryNetwork = "ethernet";
  };
}
