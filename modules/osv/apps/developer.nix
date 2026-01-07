# OSV Developer Module
#
# Provides developer tools:
# - Editors (Neovim, VS Code)
# - Languages (Rust, Go, Python, Node)
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.apps.developer;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      # Editors
      lib.optionals cfg.editors.neovim [ neovim ]
      ++ lib.optionals cfg.editors.vscode [ vscode ]

      # Languages
      ++ lib.optionals cfg.languages.rust [ rustup ]
      ++ lib.optionals cfg.languages.go [ go ]
      ++ lib.optionals cfg.languages.python [ python3 ]
      ++ lib.optionals cfg.languages.node [ nodejs ];

    # VS Code requires unfree
    nixpkgs.config.allowUnfree = lib.mkIf cfg.editors.vscode (lib.mkDefault true);
  };
}
