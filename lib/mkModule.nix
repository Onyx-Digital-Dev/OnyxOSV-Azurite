# OSV Module Construction Helper
#
# Provides utilities for building consistent OSV modules.
# Ensures uniform structure and behavior across all modules.
{ lib }:

{
  # Create a standard OSV module with consistent structure
  # Usage:
  #   mkModule {
  #     name = "core";
  #     optionPath = [ "osv" "core" ];
  #     options = { ... };
  #     config = cfg: { ... };
  #   }
  mkOsvModule = { name, optionPath, options ? {}, config ? (_: {}), imports ? [] }:
    { config, pkgs, lib, ... }:
    let
      cfg = lib.getAttrFromPath optionPath config;
    in {
      inherit imports;
      options = lib.setAttrByPath optionPath options;
      config = config cfg;
    };

  # Create an enable option with standard description
  mkEnableOpt = description:
    lib.mkEnableOption "OSV ${description}";

  # Create a package list option
  mkPackageListOpt = description:
    lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional ${description} packages";
    };

  # Create a string option with a default
  mkStrOpt = { default, description }:
    lib.mkOption {
      type = lib.types.str;
      inherit default description;
    };

  # Create a nullable string option
  mkNullableStrOpt = description:
    lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      inherit description;
    };

  # Create a boolean option with a default
  mkBoolOpt = { default, description }:
    lib.mkOption {
      type = lib.types.bool;
      inherit default description;
    };

  # Create an enum option
  mkEnumOpt = { values, default, description }:
    lib.mkOption {
      type = lib.types.enum values;
      inherit default description;
    };

  # Create a port list option
  mkPortListOpt = description:
    lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [];
      inherit description;
    };
}
