{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.waybar ];

  home-manager.users.bikkyue = {
    xdg.configFile."waybar/config".text = builtins.toJSON {
      position = "bottom";
      layer = "top";
      height = 48;
      spacing = 6;
      margin-bottom = 6;
      margin-left = 6;
      margin-right = 6;
      modules-left = [
        "custom/launcher"
        "custom/home"
        "custom/firefox"
        "custom/files"
        "custom/terminal"
        "custom/separator-apps"
        "wlr/taskbar"
      ];
      modules-right = [
        "cpu"
        "memory"
        "disk"
        "custom/separator-workspaces"
        "niri/workspaces"
        "tray"
        "wireplumber"
        "clock"
      ];

      "custom/launcher" = {
        format = "󰍉";
        tooltip = "Applications";
        on-click = "fuzzel";
      };
      "custom/home" = {
        format = "";
        tooltip = "Show desktop (right-click: previous workspace)";
        on-click = "niri msg action focus-workspace desktop";
        on-click-right = "niri msg action focus-workspace-previous";
      };
      "custom/firefox" = {
        format = "";
        tooltip = "Firefox";
        on-click = "firefox";
      };
      "custom/files" = {
        format = "";
        tooltip = "Files";
        on-click = "cosmic-files";
      };
      "custom/terminal" = {
        format = "";
        tooltip = "Terminal";
        on-click = "alacritty --working-directory /home/bikkyue";
      };
      "custom/separator-apps" = {
        format = "│";
        tooltip = false;
      };
      "custom/separator-workspaces" = {
        format = "│";
        tooltip = false;
      };
      cpu = {
        format = " {usage}%";
        tooltip = false;
        interval = 2;
      };
      memory = {
        format = " {percentage}%";
        tooltip = false;
        interval = 2;
      };
      disk = {
        format = " {percentage_used}%";
        tooltip = false;
        interval = 30;
        path = "/";
      };
      "wlr/taskbar" = {
        format = "{icon}";
        icon-size = 24;
        tooltip-format = "{title}";
        on-click = "activate";
        on-click-middle = "close";
      };
      "niri/workspaces" = {
        format = "{icon}";
        format-icons.desktop = "";
      };
      tray = {
        icon-size = 18;
        spacing = 8;
      };
      wireplumber = {
        format = "{icon} {volume}%";
        format-muted = "󰖁";
        format-icons = [
          ""
          ""
          ""
        ];
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        on-scroll-up = "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+";
        on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
      };
      clock = {
        format = "{:%H:%M}";
        tooltip-format = "{:%Y-%m-%d %A}";
      };
    };

    xdg.configFile."waybar/style.css".text = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "NotoSansM Nerd Font Mono";
        font-size: 14px;
        min-height: 0;
      }

      window#waybar {
        background: rgba(20, 22, 28, 0.72);
        color: #e6e9ef;
        border-radius: 14px;
        opacity: 1;
      }

      .modules-left {
        padding-left: 8px;
      }

      #custom-launcher,
      #custom-home,
      #custom-firefox,
      #custom-files,
      #custom-terminal,
      #cpu,
      #memory,
      #disk,
      #taskbar button,
      #workspaces button,
      #tray,
      #wireplumber,
      #clock {
        padding: 0 12px;
        margin: 5px 0;
        border-radius: 10px;
      }

      #custom-separator-apps,
      #custom-separator-workspaces {
        padding: 0 3px;
        color: rgba(230, 233, 239, 0.45);
      }

      #custom-launcher:hover,
      #custom-home:hover,
      #custom-firefox:hover,
      #custom-files:hover,
      #custom-terminal:hover,
      #cpu:hover,
      #memory:hover,
      #disk:hover,
      #taskbar button:hover,
      #workspaces button:hover {
        background: rgba(255, 255, 255, 0.12);
      }

      #taskbar button.active,
      #workspaces button.active {
        background: #89b4fa;
        color: #111318;
      }

      #taskbar button.minimized {
        opacity: 0.55;
      }

      #clock {
        margin-right: 6px;
        font-weight: bold;
      }

      #wireplumber.muted {
        opacity: 0.55;
      }
    '';
  };
}
