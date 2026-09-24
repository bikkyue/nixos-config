{ pkgs, ... }:

{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [ fcitx5-mozc ];
      settings = {
        globalOptions = {
          "Hotkey/TriggerKeys" = {
            "0" = "Menu";
            "1" = "Zenkaku_Hankaku";
          };
          "Hotkey/AltTriggerKeys"."0" = "Shift+Shift_R";
        };
        inputMethod = {
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "mozc";
          };
          "Groups/0/Items/0" = {
            Name = "keyboard-us";
            Layout = "";
          };
          "Groups/0/Items/1" = {
            Name = "mozc";
            Layout = "";
          };
          "GroupOrder"."0" = "Default";
        };
      };
    };
  };
}
