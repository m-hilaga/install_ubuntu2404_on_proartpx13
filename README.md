# Proart PX13 Ubuntu24.04 インストールメモ

## Ubuntu24.04インストール

- safe graphics でインストーラを起動
- インストーラで「プロプライエタリのパッケージをインストールする」は選択しない
- 再起動時にGRUBの画面で e キーを押し、vmlinuz のオプションで quiet splash を削除し、 nomodeset を追加して起動

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
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
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

## パッケージインストール

```
sudo apt install terminator trash-cli libreoffice libreoffice-l10n-ja zsh \
  emacs kdiff3 git git-lfs python3-venv clang g++-14 libgtest-dev hexedit cmake swig \
  ocl-icd-opencl-dev
python3 -m venv venv312
source ~/venv312/bin/activate
pip install pip_search tabulate2
sudo snap install slack
```

`clang` は `g++-14` をインストールしないと `clang++` でコンパイルエラーが出る.

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

## Nvidia関連

ドライバーをインストール. 2025/9/7現在の安定バージョンは575-server.

https://www.linux.digibeatrix.com/archives/713

```
sudo add-apt-repository ppa:graphics-drivers/ppa
sudo apt-get update
sudo apt install nvidia-driver-575-server
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
wget https://developer.download.nvidia.com/compute/cuda/12.4.1/local_installers/cuda-repo-ubuntu2204-12-4-local_12.4.1-550.54.15-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu2204-12-4-local_12.4.1-550.54.15-1_amd64.deb
sudo cp /var/cuda-repo-ubuntu2204-12-4-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cuda-toolkit-12-4
```

TensorRT 10.8 (`tensorrt`パッケージ)をインストール.

https://developer.nvidia.com/tensorrt/download/  
https://docs.nvidia.com/deeplearning/tensorrt/install-guide/index.html

```
wget https://developer.nvidia.com/downloads/compute/machine-learning/tensorrt/10.8.0/local_repo/nv-tensorrt-local-repo-ubuntu2404-10.8.0-cuda-12.8_1.0-1_amd64.deb
sudo dpkg -i nv-tensorrt-local-repo-ubuntu2404-10.8.0-cuda-12.8_1.0-1_amd64.deb
sudo cp /var/nv-tensorrt-local-repo-ubuntu2404-10.8.0-cuda-12.8/nv-tensorrt-local-90658366-keyring.gpg /usr/share/keyrings
sudo apt install tensorrt
```

NVIDIAドライバーのsuspend/resumeを有効にする.

https://note.com/sylphid_modder/n/nfa5612a989a8

```
systemctl enable nvidia-hibernate.service nvidia-resume.service nvidia-suspend.service
```

## ROCm

https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/amdgpu-install.html

`amdgpu-install`をインストール.

```
wget https://repo.radeon.com/amdgpu-install/6.3.3/ubuntu/noble/amdgpu-install_6.3.60303-1_all.deb
sudo apt install ./amdgpu-install_6.3.60303-1_all.deb
sudo apt update
```

rocm をインストール. amdgpu-dkms をインストールすると起動しなくなるので dkms はインストールしない.

```
amdgpu-install --usecase=rocmdev --no-dkms
```

render, video グループにユーザを追加.

```
sudo usermod -a -G render,video $LOGNAME
```

## VPN

https://www.fortinet.com/support/product-downloads/linux  
https://community.fortinet.com/t5/Support-Forum/Ubuntu-24-04-Forticlient-VPN-installation-w-DNS-resolution-fix/m-p/312896/highlight/true  

`forticlient` に必要なパッケージをインストール.

```
wget http://ftp.jp.debian.org/debian/pool/main/liba/libayatana-indicator/libayatana-indicator7_0.8.4-1+deb11u2_amd64.deb
wget http://ftp.jp.debian.org/debian/pool/main/liba/libayatana-appindicator/libayatana-appindicator1_0.5.5-2+deb11u2_amd64.deb
wget http://ftp.de.debian.org/debian/pool/main/libd/libdbusmenu/libdbusmenu-gtk4_18.10.20180917~bzr492+repack1-3_amd64.deb
sudo dpkg -i \
  libayatana-indicator7_0.8.4-1+deb11u2_amd64.deb \
  libayatana-appindicator1_0.5.5-2+deb11u2_amd64.deb \
  libdbusmenu-gtk4_18.10.20180917~bzr492+repack1-3_amd64.deb
```

gpg キーを設定し, fortinet の リポジトリを追加.

```
wget -O - https://repo.fortinet.com/repo/forticlient/7.4/ubuntu22/DEB-GPG-KEY | gpg --dearmor | sudo tee /usr/share/keyrings/repo.fortinet.com.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/repo.fortinet.com.gpg] https://repo.fortinet.com/repo/forticlient/7.4/ubuntu22/ stable non-free" \
  | sudo tee /etc/apt/sources.list.d/repo.fortinet.com.list
```

`forticlient` のインストール.

```
sudo apt update
sudo apt install forticlient
```

`forticlient gui` で起動し, [REMOTE ACCDESS] → [Configure VPN] メニューから, 下記マニュアル通りにサーバを設定.

https://drive.google.com/drive/folders/1CCuKMnNPEODo08fvKeqjEez6WzPtZcrt

## タッチパネル

### スクリーンキーボードの無効化

```
$ gsettings set org.gnome.desktop.a11y.applications screen-keyboard-enabled false
$ sudo apt install chrome-gnome-shell
```

Google Chrome から `https://extensions.gnome.org/extension/3222/block-caribou-36/`
にアクセスし, 拡張機能をONにする.

### サスペンドから復帰後にタッチパネルを使用可

ファイル `/etc/modprobe.d/nvidia.conf` を以下内容で作成.

```
options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/tmp
```

ファイル `/lib/systemd/system-sleep/touch-reset.sh` を以下内容で作成.

```
#!/bin/bash
if [ "$1" = "post" ]; then
    for dev in /sys/bus/i2c/drivers/i2c_hid_acpi/*:*; do
        devname=$(basename $dev)
        echo -n "$devname" > /sys/bus/i2c/drivers/i2c_hid_acpi/unbind
        echo -n "$devname" > /sys/bus/i2c/drivers/i2c_hid_acpi/bind
    done
fi
```

`/lib/systemd/system-sleep/touch-reset.sh` に実行権限を付与.

```
$ sudo chmod +x /lib/systemd/system-sleep/touch-reset.sh
```

nvidiaモジュールに正しくパラメータが設定されているかは再起動後に以下で確認できる.

```
$ grep PreserveVideoMemory /proc/driver/nvidia/params
PreserveVideoMemoryAllocations: 1
$ grep TemporaryFilePath /proc/driver/nvidia/params  
TemporaryFilePath: "/tmp"
```
