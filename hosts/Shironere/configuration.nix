{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot = {
    kernelParams = [ "memmap=1M$0x359c10000" ];
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot = {
        enable = true;
        memtest86.enable = true;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    hostName = "Shironere";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 2283 ];
  };

  users.users.bikkyue = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINSlm7kxHVoyzo2d1Sq33GoUIT98Wjf7WP9Viqd6Aru5"
    ];
  };

  programs.zsh.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global."map to guest" = "Bad User";
      share = {
        path = "/home/bikkyue/samba/share";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "force user" = "bikkyue";
        "create mask" = "0664";
        "directory mask" = "0775";
      };
    };
  };

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    docker-compose
    cloudflared
  ];

  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  services.xrdp = {
    enable = true;
    defaultWindowManager = "startplasma-x11";
    openFirewall = false;
  };

  # Shironere must remain reachable as a remote server even when Plasma is idle.
  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowHibernation = "no";
    AllowHybridSleep = "no";
    AllowSuspendThenHibernate = "no";
  };

  systemd.services.cloudflared = {
    description = "Cloudflare Tunnel";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      DynamicUser = true;
      LoadCredential = "tunnel-token:/var/lib/cloudflared/token";
      ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token-file %d/tunnel-token";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  system.stateVersion = "26.05";
}
