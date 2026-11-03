{ pkgs, ... }:

let
  nvimMimeTypes = [
    "application/javascript"
    "application/json"
    "application/toml"
    "application/typescript"
    "application/x-shellscript"
    "text/javascript"
    "text/markdown"
    "text/plain"
    "text/typescript"
    "text/x-c"
    "text/x-c++src"
    "text/x-java"
    "text/x-lua"
    "text/x-nix"
    "text/x-python"
    "text/x-rust"
  ];
in
{
  environment.systemPackages = [
    pkgs.alacritty
    (pkgs.makeDesktopItem {
      name = "nvim-terminal";
      desktopName = "Neovim (Alacritty)";
      genericName = "Text Editor";
      exec = "alacritty -e nvim %F";
      icon = "nvim";
      terminal = false;
      categories = [
        "Utility"
        "TextEditor"
      ];
      mimeTypes = nvimMimeTypes;
    })
  ];

  environment.etc."alacritty/alacritty.toml".text = ''
    [font]
    normal = { family = "NotoSansM Nerd Font Mono" }
    size = 14

    [window]
    decorations = "None"
    padding = { x = 12, y = 12 }

    [selection]
    save_to_clipboard = true

  '';

  xdg.mime.defaultApplications = builtins.listToAttrs (
    map (mimeType: {
      name = mimeType;
      value = [ "nvim-terminal.desktop" ];
    }) nvimMimeTypes
  );
}
