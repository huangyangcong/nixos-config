{ inputs, config, pkgs, lib, ... }:
let
in
{
  home.file = {
    ".cargo/config".source = ./config;
  };
}
