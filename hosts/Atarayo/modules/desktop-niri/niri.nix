{ pkgs, ... }:

{
  programs.niri.enable = true;
  security.polkit.enable = true;

  environment.systemPackages = with pkgs; [
    awww
    cosmic-files
    firefox
    xwayland-satellite
  ];

  environment.etc."niri/config.kdl".text = ''
    input {
        keyboard {
            xkb {
                layout "us"
                options "terminate:ctrl_alt_bksp,caps:menu"
            }
        }

        touchpad {
            tap
            natural-scroll
        }
    }

    layout {
        gaps 12
        default-column-width { proportion 0.5; }
        focus-ring { off; }
        border { off; }
    }

    workspace "desktop"

    window-rule {
        match app-id=r#"^Alacritty$"#
        opacity 0.85
    }

    spawn-at-startup "waybar"
    spawn-at-startup "awww-daemon"
    hotkey-overlay { }
    screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

    binds {
        Mod+Shift+Slash { show-hotkey-overlay; }
        Mod+T { spawn "alacritty"; }
        Mod+E { spawn "cosmic-files"; }
        Mod+D { spawn "fuzzel"; }
        Mod+B { spawn "firefox"; }
        Mod+Q { close-window; }
        Mod+O repeat=false { toggle-overview; }

        Mod+Left  { focus-column-left; }
        Mod+Down  { focus-window-down; }
        Mod+Up    { focus-window-up; }
        Mod+Right { focus-column-right; }
        Mod+Ctrl+Left  { move-column-left; }
        Mod+Ctrl+Down  { move-window-down; }
        Mod+Ctrl+Up    { move-window-up; }
        Mod+Ctrl+Right { move-column-right; }

        Mod+Page_Down { focus-workspace-down; }
        Mod+Page_Up   { focus-workspace-up; }
        Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
        Mod+Ctrl+Page_Up   { move-column-to-workspace-up; }

        Mod+R { switch-preset-column-width; }
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }
        Mod+V { toggle-window-floating; }

        Print { screenshot; }
        Ctrl+Print { screenshot-screen; }
        Alt+Print { screenshot-window; }
        Mod+Shift+3 { screenshot-screen; }
        Mod+Shift+4 { screenshot; }
        Mod+Shift+5 { screenshot-window; }
        Mod+Shift+S { screenshot; }

        Mod+Shift+E { quit; }
        Mod+Shift+P { power-off-monitors; }
    }
  '';
}
