let
  dir = ./.;
  files = builtins.attrNames (builtins.readDir dir);
  nixFiles = builtins.filter (
    name: builtins.match ".*\\.nix" name != null && name != "default.nix"
  ) files;
  imports = builtins.listToAttrs (
    map (file: {
      name = builtins.replaceStrings [ ".nix" ] [ "" ] file;
      value = import (dir + "/${file}");
    }) nixFiles
  );
in
imports
