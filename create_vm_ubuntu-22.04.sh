#!/bin/bash

# -x: 実行したコマンドと引数も出力する
# -e: スクリプト内のコマンドが失敗したとき（終了ステータスが0以外）にスクリプトを直ちに終了する
# -E: '-e'オプションと組み合わせて使用し、サブシェルや関数内でエラーが発生した場合もスクリプトの実行を終了する
# -u: 未定義の変数を参照しようとしたときにエラーメッセージを表示してスクリプトを終了する
# -o pipefail: パイプラインの左辺のコマンドが失敗したときに右辺を実行せずスクリプトを終了する
set -xeEuo pipefail
shopt -s inherit_errexit # '-e'オプションをサブシェルや関数内にも適用する

# このスクリプトがあるフォルダへカレントディレクトリを移動
cd "$(dirname "$0")"

# 設定
template_vm_id=9000
vm_id=123
vm_name=ubuntu-2204-${vm_id}
vm_user=ubuntu
vm_pass=ubuntu

vm_pass_hash=$(openssl passwd -6 "${vm_pass}")
cloud_config_filename=${vm_name}_cloud-config.yaml

# cloud-init
cat <<EOF > "/var/lib/vz/snippets/${cloud_config_filename}"
#cloud-config
hostname: ${vm_name}
fqdn: ${vm_name}.local

package_update: true
packages:
  - ca-certificates
  - curl
  - git
  - samba

timezone: Asia/Tokyo
locale: ja_JP.utf8
keyboard:
  layout: jp

ssh_pwauth: true

users:
  - name: ${vm_user}
    passwd: ${vm_pass_hash}
    lock_passwd: false
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: sudo
    shell: /bin/bash

runcmd:
  # nmbd だけ使いたいので smbd は停止
  - systemctl stop smbd
  - systemctl disable smbd
  # 最新の Docker をインストール
  - install -m 0755 -d /etc/apt/keyrings
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  - chmod a+r /etc/apt/keyrings/docker.asc
  - echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \$(. /etc/os-release && echo "\$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  - apt-get update
  - apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  - usermod -aG docker ${vm_user}
EOF

qm clone ${template_vm_id} ${vm_id}
qm set ${vm_id} --name ${vm_name}
qm set ${vm_id} --cores 2
qm set ${vm_id} --memory 2048
qm resize ${vm_id} scsi0 20G
qm set ${vm_id} --cicustom "user=local:snippets/${cloud_config_filename}"
