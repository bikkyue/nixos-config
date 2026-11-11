{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../common-configuration.nix
    ./modules/desktop-niri/alacritty.nix
    ./modules/desktop-niri/fcitx5.nix
    ./modules/desktop-niri/fuzzel.nix
    ./modules/desktop-niri/greetd.nix
    ./modules/desktop-niri/niri.nix
    ./modules/desktop-niri/sunshine.nix
    ./modules/desktop-niri/waybar.nix
    ./modules/typec-displayport.nix
  ];

  hardware.asahi.enable = true;
  hardware.asahi.peripheralFirmwareDirectory = /firmware;
  # Asahi カーネルのビルド済みバイナリを nix-community のキャッシュから取得する
  nix.settings = {
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    input.General.UserspaceHID = false;
  };
  systemd.services.bluetooth.serviceConfig.CapabilityBoundingSet = [
    "CAP_NET_ADMIN"
    "CAP_NET_BIND_SERVICE"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.consoleLogLevel = 1;
  boot.kernelParams = [ "quiet" ];

  networking.hostName = "Atarayo";
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };
  time.timeZone = "Asia/Tokyo";

  users.users.bikkyue.extraGroups = [ "uinput" ];

  environment.systemPackages = with pkgs; [
    vim
    git
    fastfetch
    helix
  ];

  zramSwap.enable = true;

  system.stateVersion = "26.11";
}
