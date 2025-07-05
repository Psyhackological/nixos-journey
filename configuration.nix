# Edit this configuration file to define what should be installed on your system.  Help is available in the configuration.nix(5) man page and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
    <nixos-hardware/system76>
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_zen;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8";
    LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "pl";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "pl2";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.konradkon = {
    isNormalUser = true;
    description = "Konrad Konieczny";
    extraGroups = [ "networkmanager" "wheel" ];

    # WIP PACKAGES
    packages = with pkgs; [
      # Text Editors
      vim
      neovim
      helix
      calibre
      libreoffice-fresh
      signal-desktop

      # Core
      fuzzel

      # Terminals
      alacritty
      kitty

      # Mullvad
      mullvad-browser
      mullvad

      # Media
      mpv
      tidal-hifi

      # Creative
      blender
      inkscape
      gimp3

      # Other
      fastfetch

      # Gaming
      mangohud
      protonup
    ];
  };

  

  # === WIP nix experimental ===
  nix.settings.experimental-features = [ "nix-command" "flakes"];

  # === WIP PipeWire
  # rtkit is optional but recommended
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true; # if not already enabled
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # === WIP Gnome ===
  services.xserver.displayManager.gdm.enable = true;

  services.printing.enable = true;

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
    # cudaSupport = true; # It causes OOM killer
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # === WIP SYSTEM PACKAGES ===
  environment.systemPackages = with pkgs; [
    wl-clipboard
    xwayland-satellite
    wget
    vim
    lshw
    home-manager
    mako
    waybar
    swaybg
    swayidle
    swaylock
    brightnessctl
    nvtopPackages.nvidia
    cudaPackages.cudatoolkit
  ];

  # === WIP PROGRAMS ENABLE
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = false; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    gamescopeSession.enable = true;
  };
  programs.niri.enable = true;

  programs.git = {
    enable = true;
    lfs.enable = true;
  };
  programs.ssh.startAgent = true;

  programs.fish.enable = true;
  users.users.konradkon.shell = pkgs.fish;

  # === WIP ENV ===
  environment.variables.GTK_THEME = "Adwaita:dark";
  environment.variables.EDITOR= "hx";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  # == WIP FONTS ===
  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # == NIX GARBAGE ==
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 35d";
  };

  nix.extraOptions = ''
    min-free = ${toString (2048 * 1024 * 1024)}
    max-free = ${toString (10240 * 1024 * 1024)}
  '';

  nix.settings.auto-optimise-store = true;

  # == NIX UPGRADE ==
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    channel = https://nixos.org/channels/nixos-25.05;
  };
  # === WIP GRAPHICS ==
  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };

  # Enable OpenGL
  hardware.graphics = { # hardware.graphics since NixOS 24.11
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      libvdpau-va-gl
    ];
  };
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; }; # Force intel-media-driver

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [
    "modesetting"  # example for Intel iGPU; use "amdgpu" here instead if your iGPU is AMD
    "nvidia"
  ];

  hardware.nvidia = {
    # Modsettings is required
    modesetting.enable = true;

    powerManagement.enable = false;
    powerManagement.finegrained = false;

    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };

  };
}
