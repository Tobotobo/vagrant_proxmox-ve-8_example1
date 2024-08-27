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
img_filename=jammy-server-cloudimg-amd64.img
vm_id=9000
vm_name=ubuntu-2204-template

# VirtIO SCSI コントローラーを使用して新しい VM を作成する
qm create ${vm_id}
qm set ${vm_id} --name ${vm_name}
qm set ${vm_id} --net0 virtio,bridge=vmbr0
qm set ${vm_id} --scsihw virtio-scsi-pci

# ダウンロードしたディスクを local-lvm ストレージにインポートし、SCSI ドライブとして接続する
qm importdisk ${vm_id} ${img_filename} local-lvm
qm set ${vm_id} --scsi0 local-lvm:vm-${vm_id}-disk-0

# Cloud-Init CD-ROMドライブを追加する
qm set ${vm_id} --ide2 local-lvm:cloudinit
qm set ${vm_id} --boot order=scsi0
qm set ${vm_id} --serial0 socket --vga serial0

# テンプレート化
qm template ${vm_id}
