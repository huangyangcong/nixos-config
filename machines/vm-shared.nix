{ config, pkgs, lib, currentSystem, currentSystemName, ... }:

{
  # Be careful updating this.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  nix = {
    channel.enable = false;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 3d";
    };
    # use unstable nix so we can access flakes
    package = pkgs.nixUnstable;
    #package = pkgs.nix;   # avoid using nixUnstable
    extraOptions = ''
      keep-derivations = true
    '';

    # public binary cache that I use for all my derivations. You can keep
    # this, use your own, or toss it. Its typically safe to use a binary cache
    # since the data inside is checksummed.

    settings = {
      # 去重和优化nix存储
      auto-optimise-store = true;
      download-attempts = 3;
      experimental-features = [
        "flakes"
        "nix-command"
        "repl-flake"
      ];
      fallback = true;
      keep-failed = true;
      keep-outputs = true;
      max-jobs = 3; # https://github.com/NixOS/nixpkgs/issues/198668
      #nix-path = [ "nixpkgs=/etc/nix/inputs/nixpkgs" ];
      # REF: <https://docs.cachix.org/faq#frequently-asked-questions>
      # REF: <https://nix.dev/faq#how-do-i-force-nix-to-re-check-whether-something-exists-at-a-binary-cache>
      narinfo-cache-negative-ttl = 30;
      tarball-ttl = 30;
      substituters = [
        "https://mirror.sjtu.edu.cn/nix-channels/store"
        "https://mirrors.bfsu.edu.cn/nix-channels/store"
        "https://mitchellh-nixos-config.cachix.org"
        "https://kongkong.cachix.org"
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "mitchellh-nixos-config.cachix.org-1:bjEbXJyLrL1HZZHBbO4QALnI5faYZppzkU4D2s0G8RQ="
        "kongkong.cachix.org-1:A7BRqLG8FOj5LfQtriRzq2gZZEjEDGlnLjhxdyMhSMo="
      ];
    };
  };

  nixpkgs.config.permittedInsecurePackages = [
    # Needed for k2pdfopt 2.53.
    "mupdf-1.17.0"
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # VMware, Parallels both only support this being 0 otherwise you see
  # "error switching console mode" on boot.
  boot.loader.systemd-boot.consoleMode = "0";

  # Define your hostname.
  networking.hostName = "dev";

  # Define your hosts.
  networking.extraHosts = ''
    140.82.112.3 github.com
  '';

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  # Don't require password for sudo
  security.sudo.wheelNeedsPassword = false;

  # Virtualization settings
  virtualisation.docker.enable = true;

  environment.variables = {
    GLFW_IM_MODULE = "ibus"; # Ibus & Fcitx5 solution..
  };

  # Select internationalisation properties.
  #i18n.defaultLocale = "zh_CN.UTF-8";
  #i18n.inputMethod = {
  #  enabled = "ibus";
  #  ibus.engines = with pkgs.ibus-engines; [ libpinyin rime ];
  #};
  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-rime
      ];
    };
  };

  # setup windowing environment
  services.xserver = {
    enable = true;
    layout = "us";
    dpi = 125;
    # Unlock auto unlock gnome-keyring for i3 and other WMs that don't use a display manager
    updateDbusEnvironment = true;
    desktopManager = {
      xterm.enable = false;
      wallpaper.mode = "fill"; # scale or fill
      runXdgAutostartIfNone = true; # handle XDG autostart (eg. input method)
    };

    displayManager = {
      defaultSession = "none+i3";
      lightdm = {
        enable = true;
      };

      # AARCH64: For now, on Apple Silicon, we must manually set the
      # display resolution. This is a known issue with VMware Fusion.
      sessionCommands = ''
        ${pkgs.xorg.xset}/bin/xset r rate 200 40
      '';
    };

    windowManager = {
      i3.enable = true;
    };
  };

  # Enable tailscale. We manually authenticate when we want with
  # "sudo tailscale up". If you don't use tailscale, you should comment
  # out or delete all of this.
  services.tailscale.enable = true;

  # Enable flatpak. We try not to use this (we prefer to use Nix!) but
  # some software its useful to use this and we also use it for dev tools.
  services.flatpak.enable = true;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = false;

  # Manage fonts. We pull these from a secret directory since most of these
  # fonts require a purchase.
  fonts = {
    fontDir.enable = true;
    enableDefaultFonts = true;
    fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" "JetBrainsMono" "Iosevka" ]; })
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [ "FiraCode Nerd Font" ];
      };
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    cachix
    gnumake
    killall
    niv
    rxvt_unicode
    gnupg

    # For hypervisors that support auto-resizing, this script forces it.
    # I've noticed not everyone listens to the udev events so this is a hack.
    (writeShellScriptBin "xrandr-auto" ''
      xrandr --output Virtual-1 --auto
    '')
  ] ++ lib.optionals (currentSystemName == "vm-aarch64") [
    # This is needed for the vmware user tools clipboard to work.
    # You can test if you don't need this by deleting this and seeing
    # if the clipboard sill works.
    gtkmm3
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;
  services.openssh.settings.PermitRootLogin = "no";

  # Disable the firewall since we're in a VM and we want to make it
  # easy to visit stuff in here. We only use NAT networking anyways.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
