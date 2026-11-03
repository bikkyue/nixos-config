# nixos-config

NixOSで管理する各ホストのシステム設定。
ユーザー環境（シェル、エディタなど）は
別リポジトリの`dotfiles`でHome Managerを使って管理する。

## 構成
```text
.
├── flake.nix
└── hosts/
    ├── common-configuration.nix
    ├── Atarayo/
    │   ├── configuration.nix
    │   ├── hardware-configuration.nix
    │   └── modules/desktop-niri/
    └── Shironere/
        ├── configuration.nix
        └── hardware-configuration.nix
```

- `flake.nix`: NixOSの出力と依存バージョン
- `hosts/common-configuration.nix`: ユーザー、SSH、NetworkManager、Avahi、Notoフォントなどの共通設定
- `hosts/Atarayo`: Apple Siliconマシン固有の設定
- `hosts/Atarayo/modules/desktop-niri/`: niri、greetd、fcitx5、Sunshine、Alacritty、fuzzel、Waybarなどのデスクトップ環境（設定ファイルは`/etc`に配置）
- `hosts/Shironere`: x86_64サーバー固有の設定

## 適用

```bash
git clone https://github.com/bikkyue/nixos-config.git
cd nixos-config
sudo nixos-rebuild switch --flake ".#<ホスト名>" --impure
```

`<ホスト名>`には`Atarayo`または`Shironere`を指定する。
Shironereでは、適用前に`/var/lib/cloudflared/token`を復元しておく。

システムを適用した後は、`dotfiles`でユーザー環境を適用する。

```bash
cd ../dotfiles
home-manager switch --flake . --impure
```

### Shironereの遠隔運用

ShironereではTailscaleを常時起動し、NixOSが管理するSSH、Samba、XRDPなどの
受信接続を`tailscale0`からの通信に限定する。移設先のLANにはこれらのポートを
公開しない。

初回だけ、現地へ移設する前にTailnetへ登録する。設定適用時にLAN経由のSSHが
閉じるため、以下はShironereのローカルコンソールで実行する。

```bash
sudo nixos-rebuild switch --flake ".#Shironere" --impure
sudo tailscale up
tailscale status
tailscale ip -4
```

別のTailnet参加端末からSSHと必要なサービスへ接続できること、および再起動後も
`tailscale status`が接続済みになることを確認してから移設する。アクセス可能な
ユーザーや端末はTailscaleのAccess controlsでも制限する。

Docker Composeの`ports`で`0.0.0.0`に公開したポートは、Dockerの転送規則によって
NixOSの入力ファイアウォールを迂回する場合がある。現在のImmichのTCP 2283が該当
するため、移設前にCompose側のバインド先またはDockerの`DOCKER-USER`チェインを
別途Tailnet限定にする。

## Flake更新

```bash
nix flake update
```

更新後は`nixos-rebuild switch`を再実行する。
`dotfiles`とnixpkgsの版を揃える場合は、両方のリポジトリで同時に更新する。
