# OSV Defaults
#
# Central repository for default values and constants.
# These values are used across the OSV module system.
{ lib }:

{
  # OSV version information
  version = {
    major = 1;
    minor = 0;
    patch = 0;
    codename = "Azurite";
    full = "1.0.0-Azurite";
  };

  # State version for NixOS
  stateVersion = "25.11";

  # GPU stack options
  gpu = {
    # Valid GPU stack values
    stacks = [ "intel" "amd" "nvidia" "nvidia-prime" ];

    # Default GPU stack if not specified
    defaultStack = "intel";

    # Default wrapper command name
    wrapperName = "osv-gpu-run";
  };

  # Environment/session options
  environment = {
    # Valid session types
    sessions = [ "niri" ];

    # Default session
    defaultSession = "niri";
  };

  # Networking defaults
  networking = {
    # Default fallback DNS servers
    fallbackDns = [ "1.1.1.1" "1.0.0.1" "8.8.8.8" "8.8.4.4" ];

    # Default DNSSEC mode
    dnssecMode = "allow-downgrade";
  };

  # Locale defaults
  locale = {
    defaultLocale = "en_US.UTF-8";
    defaultTimeZone = "UTC";
  };

  # App stack defaults
  apps = {
    # Gaming wrapper command
    gameWrapper = "osv-game";
    steamWrapper = "osv-steam";
  };

  # Facts template for new hosts
  factsTemplate = {
    # GPU configuration type
    # "intel" | "amd" | "nvidia" | "hybrid"
    gpu = "intel";

    # Whether this machine has an internal display (laptop panel)
    hasInternalDisplay = false;

    # Whether this is a laptop/portable device
    isLaptop = false;

    # Whether this machine has Bluetooth hardware
    hasBluetooth = true;

    # Primary network interface type
    # "ethernet" | "wifi" | "both"
    primaryNetwork = "ethernet";
  };
}
