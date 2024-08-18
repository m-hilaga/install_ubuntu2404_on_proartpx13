# Proart PX13 Ubuntu24.04 インストールメモ

## Ubuntu24.04インストール

- safe graphics でインストーラを起動
- インストーラで「プロプライエタリのパッケージをインストールする」は選択しない
- 再起動時にGRUBの画面で e キーを押し、vmlinuz のオプションで quiet splash を削除し、 nomodeset を追加して起動

## kernel 6.10.x インストール

https://note.com/yamblue/n/n7d1d2f824077

```
sudo su -
apt -y update
apt -y install make gcc flex bison libelf-dev libssl-dev dwarves bc
cd /usr/src
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.10.tar.xz
tar xfJ linux-6.10.tar.xz
cd linux-6.10
cp /boot/config-6.8.0-38-generic .config
yes "" | make oldconfig
cp .config .config.bak
```

`.config` の以下を修正

```
1183行目

CONFIG_SYSTEM_TRUSTED_KEYS="debian/canonical-certs.pem"
↓
CONFIG_SYSTEM_TRUSTED_KEYS=""

11841行目
CONFIG_SYSTEM_REVOCATION_KEYS="debian/canonical-revoked-certs.pem"
↓
CONFIG_SYSTEM_REVOCATION_KEYS=""
```

コンパイルおよびカーネルをインストール

```
make -j12 bzImage modules
make modules_install install
```

これでWiFiが利用可能に.  
ただしBluetoothは繋がらない. Mediatek MT9725（WiFi+Bluetooth）にkernelがまだ対応しきれてない？

## Gnomeの設定

- ホームディレクトリのファイル名を英語に https://qiita.com/peachft/items/fde3bebd356c17c1cef6
- capsを ctrl に
- ドックを自動で隠す
- 液晶の明るさを自動調整しない
- 電源ボタンでサスペンド
- バッテリー残量をトップバーに表示

```
LANG=C xdg-user-dirs-update --force
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:ctrl_modifier']"
gsettings set org.gnome.shell.extensions.dash-to-dock-dock-fixed false
gsettings set org.gnome.settings-daemon.plugins.power ambient-enabled false
gsettings set org.gnome.settings-daemon.plugins.power power-button-action suspend
gsettings set org.gnome.desktop.interface show-battery-percentage true
```

ノートPCを閉じても suspend させない.

https://nisshingeppo.com/ai/ubuntu-nonsleep/  

`/etc/systemd/logind.conf` に以下の行を追加.

```
HandleLidSwitch=ignore
```

最後にリブート.

## パッケージインストール

```
sudo apt install terminator fonts-vlgothic libreoffice libreoffice-l10n-ja
sudo apt install emacs kdiff3 git git-lfs virtualenv g++-14 clang
sudo snap install slack
```

`clang` は `g++-14` をインストールしないと `clang++` でコンパイルエラーが出る.

## Nvidia関連

ドライバーをインストール.

```
sudo apt install nvidia-driver-550
```

`cuda-toolkit-12-4` で必要となる `libtinfo5` (Ubuntu 24.04には無い) をインストール.

```
wget http://archive.ubuntu.com/ubuntu/pool/universe/n/ncurses/libtinfo5_6.3-2ubuntu0.1_amd64.deb
sudo dpkg -i libtinfo5_6.3-2ubuntu0.1_amd64.deb
```

`nvidia-driver-550` に対応した `cuda-toolkit-12-4` をインストール.

```
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
sudo mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/12.4.0/local_installers/cuda-repo-ubuntu2204-12-4-local_12.4.0-550.54.14-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu2204-12-4-local_12.4.0-550.54.14-1_amd64.deb
sudo cp /var/cuda-repo-ubuntu2204-12-4-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cuda-toolkit-12-4
```

TensorRT 10.3 (`tensorrt`パッケージ) をインストール.

https://developer.nvidia.com/tensorrt/download/  
https://docs.nvidia.com/deeplearning/tensorrt/install-guide/index.html

ただし `python3-libnvinfer-dev` は除く. なぜなら `python3 (< 3.11)` を満たせないので.

```
wget https://developer.nvidia.com/downloads/compute/machine-learning/tensorrt/10.3.0/local_repo/nv-tensorrt-local-repo-ubuntu2204-10.3.0-cuda-12.5_1.0-1_amd64.deb
sudo dpkg -i nv-tensorrt-local-repo-ubuntu2204-10.3.0-cuda-12.5_1.0-1_amd64.deb
sudo cp /var/nv-tensorrt-local-repo-ubuntu2204-10.3.0-cuda-12.5/*-keyring.gpg /usr/share/keyrings/
sudo apt update
sudo apt install libnvinfer* libnvonnxparsers*
```

## Git と GitHub

`git-lfs` の有効化と git の設定.

```
git lfs install
git config --global user.email "YOUR@EMAIL.ADDRESS"
git config --global user.name "YOUR NAME"
git config --global core.editor emacs
git config --global merge.tool kdiff3
```

公開キーを作成し,

```
cd
ssh-keygen -t rsa -C YOUR@EMAIL.ADDRESS
```

https://github.morphoinc.com/settings/ssh/new に `~/.ssh/id_rsa.pub` の中身を登録.

## サスペンドからの復帰

https://blog.hanhans.net/2021/04/11/reload-bluetooth-after-suspend/  

タッチスクリーン復帰のために以下を `/lib/systemd/system-sleep/multitouch` に書き込み.

```
#!/bin/sh

case $1 in
  post)
    modprobe -r hid_multitouch
    modprobe hid_multitouch
    ;;
esac
```

上記ファイルに実行権限を付与.

```
sudo chmod +x /lib/systemd/system-sleep/multitouch
```

## VPN

https://www.fortinet.com/support/product-downloads/linux  
https://community.fortinet.com/t5/Support-Forum/Ubuntu-24-04-Forticlient-VPN-installation-w-DNS-resolution-fix/m-p/312896/highlight/true  

`forticlient` に必要なパッケージをインストール.

```
wget http://ftp.jp.debian.org/debian/pool/main/liba/libayatana-indicator/libayatana-indicator7_0.8.4-1+deb11u2_amd64.deb
wget http://ftp.jp.debian.org/debian/pool/main/liba/libayatana-appindicator/libayatana-appindicator1_0.5.5-2+deb11u2_amd64.deb
wget http://security.ubuntu.com/ubuntu/pool/universe/libd/libdbusmenu/libdbusmenu-gtk4_18.10.20180917~bzr492+repack1-3ubuntu1_amd64.deb
sudo dpkg -i \
  libayatana-indicator7_0.8.4-1+deb11u2_amd64.deb \
  libayatana-appindicator1_0.5.5-2+deb11u2_amd64.deb \
  libdbusmenu-gtk4_18.10.20180917~bzr492+repack1-3ubuntu1_amd64.deb
```

gpg キーを設定し, fortinet の リポジトリを追加.

```
wget -O - https://repo.fortinet.com/repo/forticlient/7.4/ubuntu22/DEB-GPG-KEY | gpg --dearmor | sudo tee /usr/share/keyrings/repo.fortinet.com.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/repo.fortinet.com.gpg] https://repo.fortinet.com/repo/forticlient/7.4/ubuntu22/ stable non-free" \
  | sudo tee /etc/apt/sources.list.d/repo.fortinet.com.list
```

`forticlient` のインストール.

```
sudo apt updte
sudo apt install forticlient
```

`forticlient gui` で起動し, 下記マニュアルを通りにサーバを設定.

https://drive.google.com/drive/folders/1CCuKMnNPEODo08fvKeqjEez6WzPtZcrt
