# OSV Users Module
#
# Provides user account configuration.
# Hosts set the primary user; this module implements the policy.
{ config, lib, pkgs, ... }:

let
  cfg = config.osv.users;
in
{
  config = lib.mkIf (cfg.primaryUser != null) {
    users.users.${cfg.primaryUser} = {
      isNormalUser = true;
      description = cfg.primaryUserDescription;
      extraGroups = cfg.extraGroups;
    };
  };
}
