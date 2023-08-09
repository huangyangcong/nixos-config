{ pkgs, ... }:

{
  # https://github.com/nix-community/home-manager/pull/2408
  environment.pathsToLink = [ "/share/fish" ];

  # Since we're using fish as our shell
  programs.fish.enable = true;

  users.users.kongkong = {
    isNormalUser = true;
    home = "/home/kongkong";
    extraGroups = [ "docker" "wheel" ];
    shell = pkgs.fish;
    hashedPassword = "$y$j9T$9CNrP3FF8JLeI1jbtr5ad1$KL9HgNormExOEfNVgu2gqQZmiRs4xU2mOH5g3NOcrC7";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGI8uBbahndsxTZinHEjWpQLLkWWIxKxVM0wOW8huzdw kongkong"
    ];
  };

  nixpkgs.overlays = import ../../lib/overlays.nix ++ [
    (import ./vim.nix)
  ];
}
