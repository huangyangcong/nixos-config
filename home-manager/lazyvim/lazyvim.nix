{ inputs, config, pkgs, lib, ... }:
let
  sources = import ../../nix/sources.nix;
in {
  home.file = {
	nvim = {
      source = sources.LazyVim;
      target = "./.config/nvim";
      recursive = true;
    };
  };
}
