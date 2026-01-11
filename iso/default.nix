# ═══════════════════════════════════════════════════════════════════════════════
# ONYX OSV v0.2 - Azurite Installation ISO
# ═══════════════════════════════════════════════════════════════════════════════
#
# Custom NixOS installer ISO with OSV pre-loaded.
# Build with: nix build .#iso
#
{ config, lib, pkgs, modulesPath, ... }:

let
  # OSV Bootstrap script
  osv-bootstrap = pkgs.writeShellScriptBin "osv-bootstrap" (builtins.readFile ../osv-bootstrap);

  # Welcome message
  welcomeMessage = ''

    ╔═══════════════════════════════════════════════════════════════════════════════╗
    ║                                                                               ║
    ║   ██████╗ ███╗   ██╗██╗   ██╗██╗  ██╗     ██████╗ ███████╗██╗   ██╗          ║
    ║  ██╔═══██╗████╗  ██║╚██╗ ██╔╝╚██╗██╔╝    ██╔═══██╗██╔════╝██║   ██║          ║
    ║  ██║   ██║██╔██╗ ██║ ╚████╔╝  ╚███╔╝     ██║   ██║███████╗██║   ██║          ║
    ║  ██║   ██║██║╚██╗██║  ╚██╔╝   ██╔██╗     ██║   ██║╚════██║╚██╗ ██╔╝          ║
    ║  ╚██████╔╝██║ ╚████║   ██║   ██╔╝ ██╗    ╚██████╔╝███████║ ╚████╔╝           ║
    ║   ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝     ╚═════╝ ╚══════╝  ╚═══╝            ║
    ║                                                                               ║
    ║                        v0.2 Azurite - Installation ISO                        ║
    ║                                                                               ║
    ╚═══════════════════════════════════════════════════════════════════════════════╝

    Welcome to the ONYX OSV Installer!

    QUICK START:
      sudo osv-install        Run the full automated installer

    NETWORK:
      nmtui                   Connect to WiFi
      ip a                    Show network interfaces

    UTILITIES:
      lsblk                   List disks and partitions
      htop                    System monitor

    The OSV repository is pre-loaded at: /osv

  '';

in {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  # ═══════════════════════════════════════════════════════════════════════════════
  # ISO METADATA
  # ═══════════════════════════════════════════════════════════════════════════════

  isoImage = {
    isoName = lib.mkForce "osv-azurite-${config.system.nixos.label}-x86_64.iso";
    volumeID = lib.mkForce "OSV_AZURITE";

    # Append OSV identifier to boot menu
    appendToMenuLabel = " - ONYX OSV Installer";
  };

  # ═══════════════════════════════════════════════════════════════════════════════
  # SYSTEM CONFIGURATION
  # ═══════════════════════════════════════════════════════════════════════════════

  # Hostname for installer
  networking.hostName = "osv-installer";

  # Enable NetworkManager for easy WiFi
  networking.networkmanager.enable = true;
  networking.wireless.enable = lib.mkForce false;

  # Allow unfree (for potential firmware)
  nixpkgs.config.allowUnfree = true;

  # ═══════════════════════════════════════════════════════════════════════════════
  # PACKAGES
  # ═══════════════════════════════════════════════════════════════════════════════

  environment.systemPackages = with pkgs; [
    # OSV installer
    osv-bootstrap

    # Essential tools
    git
    vim
    nano
    htop
    tmux

    # Disk utilities
    parted
    gptfdisk
    dosfstools
    e2fsprogs
    btrfs-progs

    # Network
    networkmanager
    wget
    curl

    # Hardware info
    pciutils
    usbutils
    lshw

    # Filesystem
    ntfs3g
    exfatprogs
  ];

  # ═══════════════════════════════════════════════════════════════════════════════
  # OSV REPOSITORY (PRE-LOADED)
  # ═══════════════════════════════════════════════════════════════════════════════

  # Copy OSV repo to /osv in the ISO
  environment.etc."osv-repo".source = pkgs.runCommand "osv-repo" {} ''
    mkdir -p $out
    cp -r ${../flake.nix} $out/flake.nix
    cp -r ${../flake.lock} $out/flake.lock 2>/dev/null || true
    cp -r ${../hosts} $out/hosts
    cp -r ${../modules} $out/modules
    cp -r ${../lib} $out/lib
    cp -r ${../overlays} $out/overlays
    cp -r ${../osv-bootstrap} $out/osv-bootstrap
    cp -r ${../osv-install} $out/osv-install
    chmod +x $out/osv-bootstrap $out/osv-install
  '';

  # Symlink to /osv for convenience
  environment.etc."profile.local".text = ''
    # Create /osv symlink on boot
    if [ ! -L /osv ]; then
      sudo ln -sf /etc/osv-repo /osv 2>/dev/null || true
    fi
  '';

  # ═══════════════════════════════════════════════════════════════════════════════
  # INSTALLER SCRIPT (WRAPPED)
  # ═══════════════════════════════════════════════════════════════════════════════

  # Create osv-install wrapper that uses pre-loaded repo
  environment.etc."profile.d/osv-install.sh".text = ''
    osv-install() {
      echo "Starting OSV Installer..."
      echo ""

      # Check network
      if ! ping -c 1 -W 3 1.1.1.1 &> /dev/null; then
        echo "⚠ No network connection detected!"
        echo "  Connect with: nmtui"
        echo ""
        read -p "Continue anyway? [y/N]: " response
        [[ ! "$response" =~ ^[Yy]$ ]] && return 1
      fi

      sudo /run/current-system/sw/bin/osv-bootstrap
    }
    export -f osv-install
  '';

  # ═══════════════════════════════════════════════════════════════════════════════
  # WELCOME MESSAGE
  # ═══════════════════════════════════════════════════════════════════════════════

  # Show welcome on login
  environment.etc."motd".text = welcomeMessage;

  # Also set as issue for TTY
  environment.etc."issue".text = welcomeMessage;

  # ═══════════════════════════════════════════════════════════════════════════════
  # AUTO-LOGIN (Optional convenience)
  # ═══════════════════════════════════════════════════════════════════════════════

  # Auto-login to root on TTY1
  services.getty.autologinUser = lib.mkForce "root";

  # ═══════════════════════════════════════════════════════════════════════════════
  # SHELL CONFIGURATION
  # ═══════════════════════════════════════════════════════════════════════════════

  programs.bash = {
    interactiveShellInit = ''
      # Create /osv symlink if not exists
      [ ! -L /osv ] && ln -sf /etc/osv-repo /osv 2>/dev/null

      # Helpful aliases
      alias install='osv-install'
      alias wifi='nmtui'
      alias disks='lsblk -f'

      # Show quick help on first login
      if [ -z "$OSV_WELCOMED" ]; then
        export OSV_WELCOMED=1
        echo ""
        echo -e "\033[1;36mType 'osv-install' to begin installation\033[0m"
        echo ""
      fi
    '';
  };

  # ═══════════════════════════════════════════════════════════════════════════════
  # HARDWARE SUPPORT
  # ═══════════════════════════════════════════════════════════════════════════════

  # Enable firmware for broader hardware support
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  # ═══════════════════════════════════════════════════════════════════════════════
  # BOOT
  # ═══════════════════════════════════════════════════════════════════════════════

  # Quieter boot
  boot.consoleLogLevel = 3;
  boot.kernelParams = [ "quiet" ];
}
