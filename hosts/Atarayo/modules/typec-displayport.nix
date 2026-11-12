# Type-C ポートから DisplayPort 出力（DP Alt Mode）を出すための設定
#
# - Asahi の fairydust ブランチ（DP Alt Mode 開発版）のカーネルを使う。
#   t8112-j473.dts で ENABLE_DCPEXT_TYPEC が有効になり、
#   dcp（disp0）を Type-C ポート（atcphy1 / typec1）の DP 出力に割り当てる。
# - KVM の切り替え後に映像が戻らない問題への対処として、DP を自動で接続し直す。
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # apple-silicon-support のカーネル設定（"Asahi config" とユーザーのパッチ）を流用する
  asahiKernel =
    (config.hardware.asahi.pkgs.linux-asahi.override {
      _kernelPatches = config.boot.kernelPatches;
    }).kernel;

  fairydustKernel = pkgs.buildLinux rec {
    pname = "linux-asahi-fairydust";
    version = "7.2.15";
    modDirVersion = version;
    extraMeta.branch = "7.2";
    src = pkgs.fetchFromGitHub {
      owner = "AsahiLinux";
      repo = "linux";
      rev = "432e09dca5d88e145eba6ff6080cd77aa5b8ccf8"; # fairydust (2026-11-05)
      hash = "sha256-oB40IG6UgwgklAO8J09KY8/FPzF5nklvKvZe8A2/2Pg=";
    };
    kernelPatches = asahiKernel.kernelPatches ++ [
      {
        # DP の切断時に DCP を誤ってクラッシュ扱いにし、再起動まで出力できなくなる問題を直す
        name = "apple-dcp-poweroff-no-false-crash";
        patch = ./patches/apple-dcp-poweroff-no-false-crash.patch;
      }
    ];
  };

  # KVM を切り替えるとハブは Mac に何も通知せず映像が途切れたままになるため、
  # Type-C コントローラ（port1 = i2c 0-003f）のドライバを付け直して DP を接続し直す
  dpStamp = "/run/dp-relink.stamp";
  dpRelinkRoot = pkgs.writeShellScript "dp-relink-root" ''
    set -eu
    drv=/sys/bus/i2c/drivers/tps6598x
    # i2c のバス番号は起動ごとに変わる（0-003f / 1-003f など）ので、アドレス 0x3f で探す
    dev=""
    for d in /sys/bus/i2c/devices/*-003f; do
      [ "$(${pkgs.coreutils}/bin/cat "$d/name" 2>/dev/null)" = "cd321x" ] && dev=$(${pkgs.coreutils}/bin/basename "$d")
    done
    if [ -z "$dev" ]; then
      echo "error: Type-C controller (i2c *-003f) not found" >&2
      exit 1
    fi

    # --auto: KVM 経由の USB 機器の接続をきっかけに udev から呼ばれる。
    # 直近 20 秒以内に付け直したか、ハブが接続されたばかりなら DP も成立したばかりなので何もしない。
    # （付け直すと USB 機器も接続し直されるので、これがないと無限に繰り返す）
    if [ "''${1:-}" = "--auto" ]; then
      if [ -e ${dpStamp} ] && [ $(( $(${pkgs.coreutils}/bin/date +%s) - $(${pkgs.coreutils}/bin/stat -c %Y ${dpStamp}) )) -lt 20 ]; then
        echo "skip: DP was (re)connected recently"
        exit 0
      fi
      # KVM が映像を切り替え終えるのを待つ
      sleep 2
    fi

    # --boot: 起動時は Type-C コントローラが表示ドライバより先に DP の接続を通知してしまい、
    # 通知が失われて DP-1 が未接続のままになる。DP-1 ができるのを待ち、
    # Type-C の先に機器があるのに未接続なら付け直す。
    if [ "''${1:-}" = "--boot" ]; then
      for _ in $(${pkgs.coreutils}/bin/seq 30); do
        status=$(${pkgs.coreutils}/bin/cat /sys/class/drm/card*-DP-1/status 2>/dev/null || true)
        [ -n "$status" ] && break
        sleep 1
      done
      if [ ! -e /sys/class/typec/port1-partner ] || [ "$status" = "connected" ]; then
        echo "skip: nothing to do at boot (status=''${status:-none})"
        exit 0
      fi
    fi

    ${pkgs.coreutils}/bin/touch ${dpStamp}
    echo "relinking DP via $dev"
    if [ -e "$drv/$dev" ]; then
      echo "$dev" > "$drv/unbind"
      sleep 2
    fi
    echo "$dev" > "$drv/bind"
  '';
  dpRelink = pkgs.writeShellScriptBin "dp-relink" ''
    exec /run/wrappers/bin/sudo ${dpRelinkRoot}
  '';
in
{
  boot.kernelPackages = lib.mkForce (pkgs.linuxPackagesFor fairydustKernel);

  # - Type-C ハブ（port1 = xhci 502280000 の直下）の接続：ケーブルを挿した直後で DP も成立するので時刻だけ記録する
  # - KVM の USB ハブ（本体 USB-A = PCIe xhci 690000000 の直下）の接続：
  #   KVM が Mac に切り替わったので DP を接続し直す
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", DEVPATH=="/devices/platform/soc/502280000.usb/*", KERNEL=="[0-9]*-[0-9]*", KERNEL!="*.*", RUN+="${pkgs.coreutils}/bin/touch ${dpStamp}"
    ACTION=="add", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", DEVPATH=="/devices/platform/soc/690000000.pcie/*", KERNEL=="[0-9]*-[0-9]*", KERNEL!="*.*", TAG+="systemd", ENV{SYSTEMD_WANTS}+="dp-relink.service"
  '';

  systemd.services.dp-relink = {
    description = "Re-establish Type-C DisplayPort link after KVM switch";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${dpRelinkRoot} --auto";
    };
  };

  systemd.services.dp-relink-boot = {
    description = "Re-establish Type-C DisplayPort link at boot";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-udev-settle.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${dpRelinkRoot} --boot";
    };
  };

  environment.systemPackages = [ dpRelink ];
  security.sudo.extraRules = [
    {
      users = [ "bikkyue" ];
      commands = [
        {
          command = "${dpRelinkRoot}";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
