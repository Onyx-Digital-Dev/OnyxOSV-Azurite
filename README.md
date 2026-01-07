# ONYX OSV (Azurite)

Enterprise-grade, flake-based NixOS distribution.

## Target

- NixOS 25.11 (stable)
- Wayland-only (Niri + DankMaterialShell)
- Deterministic, reproducible builds

## Structure

```
onyx/
├── flake.nix           # Single source of truth
├── lib/                # Pure helper functions
├── hosts/              # Host configurations
│   ├── wraith/         # NVIDIA PRIME testbed
│   └── template/       # New host template
├── modules/osv/        # OSV module system
│   ├── options.nix     # ALL option definitions
│   ├── core.nix        # Core baseline
│   ├── networking.nix  # Network stack
│   ├── users.nix       # User management
│   ├── hardware/       # Hardware modules
│   ├── environment/    # Desktop environment
│   ├── apps/           # Application stacks
│   └── meta/           # Invariants & logging
└── overlays/           # Package overlays
```

## Quick Start

```bash
# Build for Wraith
nix build .#nixosConfigurations.wraith.config.system.build.toplevel

# Switch to new configuration
sudo nixos-rebuild switch --flake .#wraith
```

## Hosts

- **wraith**: NVIDIA PRIME hybrid laptop (primary testbed)
- **template**: Starting point for new hosts

## GPU Stacks

Select via `osv.hardware.gpu.stack`:

- `intel`: Intel integrated graphics
- `amd`: AMD graphics
- `nvidia`: NVIDIA discrete only
- `nvidia-prime`: Intel + NVIDIA hybrid (PRIME offload)
