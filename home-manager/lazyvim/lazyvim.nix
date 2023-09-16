{ inputs, config, pkgs, lib, ... }:
let
  sources = import ../../nix/sources.nix;
in
{
  home.file = {
    ".config/nvim" = {
      source = ./src;
      recursive = true;
    };
  };
}
