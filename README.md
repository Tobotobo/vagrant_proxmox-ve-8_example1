# vagrant_proxmox-ve-8_example1

## 概要

* 未完成　→　作ったインスタンスがネットにつながらない　→　仮想がネストしているからだと思われるが調査中
* Proxmox VE 8 の勉強環境を Vagrant で作成する
* 再現性や自動化のため、操作は基本的に画面ではなくコマンドで行う
* Proxmox VE や Vagrant 自体については説明しないので適当にググること

### 参照
* [Proxmox Virtual Environment](https://www.proxmox.com/en/proxmox-virtual-environment/overview)    
  Proxmox Virtual Environment は、エンタープライズ仮想化のための完全なオープンソース サーバー管理プラットフォームです。

* [Vagrant](https://www.vagrantup.com/)    
  Vagrant（ベイグラント）は、仮想機械を構築するためのソフトウェアである。 構成情報を記述した設定ファイル (Vagrantfile) を元に、仮想環境の構築から設定までを自動的に行うことができる。 

* [Vagrant Cloud - clincha/proxmox-ve-8](https://app.vagrantup.com/clincha/boxes/proxmox-ve-8)  

## 環境
* Ubuntu 24.04
* VirtualBox 7.0
* Vagrant 2.4.1


## 詳細

### 実行手順
* `vagrant up` で ProxmoxVE の VM を起動する
* `vagrant ssh` で起動した VM にログインする
* `sudo -i` で root に切り替える
* `cd /vagrant` でフォルダを移動する
* `chmod +x *.sh`
* `./setup_snippets.sh` で cloud-init の設定ファイルを格納できるよう設定する
* `./download_image_ubuntu-22.04.sh` でクラウドイメージをダウンロード  
  ※直下に jammy-server-cloudimg-amd64.img がダウンロードされる（約650MB）  
* `./create_template_ubuntu-22.04.sh` でクラウドイメージからテンプレートを作成する
* `./create_vm_ubuntu-22.04.sh` でテンプレートを基にインスタンスを作成する  
  ※`No such file or directory` エラーになった場合は snippets フォルダの作成が完了していないので、少し待ってから再度実行する
* 管理画面にログインし `9000:ubuntu-2204-template` と `123:ubuntu-2204-123` が作成されていることを確認する
* `123:ubuntu-2204-123` を開始する  
  ※ cloud-init の実行等で起動後もしばらく処理してる
* ID:ubuntu, PW: ubuntu でログイン  
以上

### 管理画面

http://192.168.56.10:8006  
ID: root  
PW: vagrant  
