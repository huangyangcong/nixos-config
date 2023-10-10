{ inputs, config, pkgs, lib, ... }:
let
in
{
  home.file = {
    ".pip/pip.conf".source = ./pip.conf;
  };
}
