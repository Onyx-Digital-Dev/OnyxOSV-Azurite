# OSV Developer SIP
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
    (lib.mkIf (cfg.formatter == "alejandra") {
      environment.systemPackages = [ pkgs.alejandra ];
    })
    (lib.mkIf (cfg.formatter == "nixfmt") {
      environment.systemPackages = [ pkgs.nixfmt-rfc-style ];
    })

    (lib.mkIf (cnt.enable && cnt.docker) {
      virtualisation.docker.enable = true;
      environment.systemPackages = [ pkgs.docker-compose ];
    })

    (lib.mkIf (edt.enable && edt.vscodium) {
      environment.systemPackages = [ pkgs.vscodium ];
    })
    (lib.mkIf (edt.enable && edt.neovim) {
      environment.systemPackages = [ pkgs.neovim ];
    })

    (lib.mkIf (lng.enable && lng.rust) {
      environment.systemPackages = with pkgs; [ rustup pkg-config ];
    })
    (lib.mkIf (lng.enable && lng.python) {
      environment.systemPackages = with pkgs; [
        python3
        python3Packages.pip
        python3Packages.virtualenv
      ];
    })

    (lib.mkIf core.enable {
      environment.systemPackages = with pkgs; [
        git-lfs
        gnumake cmake ninja meson
        gcc clang llvm binutils
        gdb ltrace valgrind
        patchelf elfutils
        fzf
        yq
        httpie
        nix-prefetch-git nix-prefetch-github nixpkgs-review nix-tree nix-diff
      ];
      programs.nix-ld.enable = true;
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    })

    {
      environment.systemPackages = with pkgs; [ man-pages man-pages-posix ];
      documentation = {
        dev.enable = true;
        man.enable = true;
      };
    }
  ]);
}
