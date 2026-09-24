{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    fuzzel
  ];

  home-manager.users.bikkyue.xdg.configFile."fuzzel/fuzzel.ini".text = ''
    [main]
    font=NotoSansM Nerd Font Mono:size=18
    prompt=󰍉${"  "}
    placeholder=アプリを検索...
    lines=10
    width=50
    horizontal-pad=32
    vertical-pad=24
    inner-pad=12
    icon-theme=Adwaita
    layer=overlay

    [colors]
    background=14161ce6
    text=e6e9efff
    prompt=89b4faff
    placeholder=6c7086ff
    input=cdd6f4ff
    match=f9e2afff
    selection=89b4faff
    selection-text=111318ff
    selection-match=111318ff
    border=89b4faff

    [border]
    width=2
    radius=14
  '';
}
