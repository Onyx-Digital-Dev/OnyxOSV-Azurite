# OSV Developer SIP
#
# Professional development tools. Primary workflow is nix-shell/devShells.
# Does NOT configure GPU, audio, or AI tooling.
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.apps.developer;
  cnt = cfg.containers;
  edt = cfg.editors;
  lng = cfg.languages;
  core = cfg.coreTools;
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    # Formatter
    (lib.mkIf (cfg.formatter == "alejandra") {
      environment.systemPackages = [ pkgs.alejandra ];
    })
    (lib.mkIf (cfg.formatter == "nixfmt") {
      environment.systemPackages = [ pkgs.nixfmt-rfc-style ];
    })

    # Containers
    (lib.mkIf (cnt.enable && cnt.docker) {
      virtualisation.docker.enable = true;
      environment.systemPackages = [ pkgs.docker-compose ];
    })

    # Editors
    (lib.mkIf (edt.enable && edt.vscodium) {
      environment.systemPackages = [ pkgs.vscodium ];
    })
    (lib.mkIf (edt.enable && edt.helix) {
      environment.systemPackages = [ pkgs.helix ];
    })
    (lib.mkIf (edt.enable && edt.neovim) {
      environment.systemPackages = [ pkgs.neovim ];
    })

    # Languages (baseline capability)
    (lib.mkIf (lng.enable && lng.rust) {
      environment.systemPackages = with pkgs; [ rustup pkg-config openssl ];
    })
    (lib.mkIf (lng.enable && lng.python) {
      environment.systemPackages = with pkgs; [
        python3
        python3Packages.pip
        python3Packages.virtualenv
      ];
    })

    # Core tooling
    (lib.mkIf core.enable {
      environment.systemPackages = with pkgs; [
        git git-lfs
        gnumake cmake ninja meson
        gcc clang llvm binutils
        gdb strace ltrace valgrind
        file patchelf elfutils
        ripgrep fd tree fzf
        jq yq
        curl wget httpie
        nix-prefetch-git nix-prefetch-github nixpkgs-review nix-tree nix-diff
      ];
      programs.nix-ld.enable = true;
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    })

    # Common
    {
      environment.systemPackages = with pkgs; [ man-pages man-pages-posix ];
      documentation = {
        dev.enable = true;
        man.enable = true;
      };
    }
  ]);
}
