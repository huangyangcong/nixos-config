{ pkgs, fetchFromGitHub }:
pkgs.stdenv.mkDerivation {
  name = "telescope-fzf-native";
  installPhase = ''
    mkdir -p $out/build
    cp build/libfzf.so $out/build/libfzf.so
  '';
  src = fetchFromGitHub {
    owner = "nvim-telescope";
    repo = "telescope-fzf-native.nvim";
    rev = "6c921ca12321edaa773e324ef64ea301a1d0da62";
    sha256 = "sha256-Hob1x/jwQYfphYGWQ/i44NVyCM+WFT5/4+J5J4/tLYA=";
  };
}
