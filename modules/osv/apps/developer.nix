# OSV Developer SIP (Software Intent Profile)
#
# PURPOSE:
# "This system is ready for professional software development immediately,
# across common languages and workflows, without blocking on missing tools,
# while still encouraging project-specific dependency isolation via nix-shell."
#
# DOCTRINE: "A warrior in a garden, not a gardener in a war."
# Unused capability is acceptable. Over-capability is intentional.
#
# BOUNDARY: This module provides developer SOFTWARE ONLY.
# It does NOT configure:
#   - GPU drivers or acceleration (see osv.hardware.gpu.*)
#   - Audio stack/PipeWire (see osv.core.audio.*)
#   - Webcams, microphones, or capture devices
#   - Display managers or sessions (see osv.environment.*)
#   - Kernel parameters or hardware-level settings
#   - AI tooling (explicitly excluded)
#
# PRIMARY WORKFLOW:
#   nix-shell / devShells for project-specific dependencies.
#   System languages are baseline capability, not replacement for shells.
#
# COMPOSABILITY:
#   This SIP is designed to work alongside other SIPs (gaming, creator)
#   without conflicts. All packages are additive to environment.systemPackages.
#
# ═══════════════════════════════════════════════════════════════════════════════
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.apps.developer;

  # Shorthand for category enables
  cnt = cfg.containers;
  edt = cfg.editors;
  lng = cfg.languages;
  core = cfg.coreTools;
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    # ═══════════════════════════════════════════════════════════════════════
    # NIX FORMATTER
    # ═══════════════════════════════════════════════════════════════════════
    #
    # Formatter selection via enum. No formatter is mandatory.
    # "If a developer can code, they can select their formatter."
    #

    # Alejandra - Opinionated Nix formatter
    (lib.mkIf (cfg.formatter == "alejandra") {
      environment.systemPackages = [ pkgs.alejandra ];
    })

    # nixfmt - Official Nix formatter
    (lib.mkIf (cfg.formatter == "nixfmt") {
      environment.systemPackages = [ pkgs.nixfmt-rfc-style ];
    })

    # ═══════════════════════════════════════════════════════════════════════
    # CONTAINERS
    # ═══════════════════════════════════════════════════════════════════════
    #
    # Container runtime for development workflows.
    # Docker is the standard; compose tooling included.
    #

    # Docker + Docker Compose
    (lib.mkIf (cnt.enable && cnt.docker) {
      virtualisation.docker = {
        enable = true;
        # Rootless is more secure but requires user setup
        # Default to root daemon for compatibility
      };

      # Docker CLI tools
      environment.systemPackages = with pkgs; [
        docker-compose
      ];

      # Primary user needs docker group membership
      # This is handled by user configuration, not here
    })

    # ═══════════════════════════════════════════════════════════════════════
    # EDITORS
    # ═══════════════════════════════════════════════════════════════════════
    #
    # Code editors for professional development.
    # VSCodium (FOSS), Helix (modern modal), Neovim (classic modal).
    #

    # VSCodium - FOSS VS Code without Microsoft telemetry
    (lib.mkIf (edt.enable && edt.vscodium) {
      environment.systemPackages = [ pkgs.vscodium ];
    })

    # Helix - Post-modern modal text editor
    # Built-in LSP support, tree-sitter, multiple selections
    (lib.mkIf (edt.enable && edt.helix) {
      environment.systemPackages = [ pkgs.helix ];
    })

    # Neovim - Hyperextensible Vim-based text editor
    (lib.mkIf (edt.enable && edt.neovim) {
      environment.systemPackages = [ pkgs.neovim ];
    })

    # ═══════════════════════════════════════════════════════════════════════
    # LANGUAGES (Baseline Capability)
    # ═══════════════════════════════════════════════════════════════════════
    #
    # System-level language toolchains for baseline capability.
    #
    # IMPORTANT: These are NOT replacements for project-specific devShells.
    # The PRIMARY expected workflow is nix-shell / devShells for project deps.
    # System languages exist to ensure basic capability is always present.
    #

    # Rust - Systems programming language
    # Using rustup for toolchain management flexibility
    (lib.mkIf (lng.enable && lng.rust) {
      environment.systemPackages = with pkgs; [
        rustup
        # Commonly needed for building Rust projects
        pkg-config
        openssl
      ];
    })

    # Python - General purpose programming language
    (lib.mkIf (lng.enable && lng.python) {
      environment.systemPackages = with pkgs; [
        python3
        python3Packages.pip
        python3Packages.virtualenv
      ];
    })

    # ═══════════════════════════════════════════════════════════════════════
    # CORE DEVELOPMENT TOOLING
    # ═══════════════════════════════════════════════════════════════════════
    #
    # Baseline utilities required for:
    # • Building (make, cmake, gcc, clang)
    # • Debugging (gdb, strace, ltrace)
    # • Inspection (file, binutils, patchelf)
    # • Iteration (git, ripgrep, fd, jq)
    #
    # Conservative and broadly useful. No niche or opinionated tools.
    #

    (lib.mkIf core.enable {
      environment.systemPackages = with pkgs; [
        # ─────────────────────────────────────────────────────────────────
        # Version Control
        # ─────────────────────────────────────────────────────────────────
        git
        git-lfs

        # ─────────────────────────────────────────────────────────────────
        # Build Systems
        # ─────────────────────────────────────────────────────────────────
        gnumake
        cmake
        ninja
        meson

        # ─────────────────────────────────────────────────────────────────
        # Compilers & Toolchains
        # ─────────────────────────────────────────────────────────────────
        gcc
        clang
        llvm
        binutils

        # ─────────────────────────────────────────────────────────────────
        # Debugging
        # ─────────────────────────────────────────────────────────────────
        gdb
        strace
        ltrace
        valgrind

        # ─────────────────────────────────────────────────────────────────
        # Binary Inspection & Manipulation
        # ─────────────────────────────────────────────────────────────────
        file
        patchelf
        elfutils

        # ─────────────────────────────────────────────────────────────────
        # Search & Navigation
        # ─────────────────────────────────────────────────────────────────
        ripgrep
        fd
        tree
        fzf

        # ─────────────────────────────────────────────────────────────────
        # Data Processing
        # ─────────────────────────────────────────────────────────────────
        jq
        yq

        # ─────────────────────────────────────────────────────────────────
        # Network Utilities
        # ─────────────────────────────────────────────────────────────────
        curl
        wget
        httpie

        # ─────────────────────────────────────────────────────────────────
        # Nix Development
        # ─────────────────────────────────────────────────────────────────
        nix-prefetch-git
        nix-prefetch-github
        nixpkgs-review
        nix-tree
        nix-diff
      ];

      # Enable nix-ld for running unpatched binaries
      programs.nix-ld.enable = true;

      # Direnv for automatic shell activation
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    })

    # ═══════════════════════════════════════════════════════════════════════
    # COMMON DEVELOPER STACK
    # ═══════════════════════════════════════════════════════════════════════
    #
    # Always-present baseline when Developer SIP is enabled.
    #
    {
      environment.systemPackages = with pkgs; [
        # Man pages for development
        man-pages
        man-pages-posix
      ];

      # Enable documentation
      documentation = {
        dev.enable = true;
        man.enable = true;
      };
    }
  ]);
}
