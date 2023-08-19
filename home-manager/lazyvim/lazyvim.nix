{ inputs, config, pkgs, lib, ... }:
let
  sources = import ../../nix/sources.nix;
in
{
  home.file = {
    nvim = {
      source = ./src;
      target = "./.config/nvim";
      recursive = true;
    };
  };
}
