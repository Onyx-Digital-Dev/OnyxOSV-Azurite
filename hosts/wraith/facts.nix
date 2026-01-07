# Wraith Host Facts
#
# STATIC hardware facts for Wraith.
# Derived from hardware inspection, not runtime probing.
#
# This file is DATA ONLY - no logic.
{ ... }:

{
  osv.facts = {
    # Intel iGPU + NVIDIA dGPU (hybrid laptop)
    gpu = "hybrid";

    # Has built-in laptop display
    hasInternalDisplay = true;

    # Is a laptop
    isLaptop = true;

    # Has Bluetooth hardware
    hasBluetooth = true;

    # Has both ethernet and wifi
    primaryNetwork = "both";
  };
}
