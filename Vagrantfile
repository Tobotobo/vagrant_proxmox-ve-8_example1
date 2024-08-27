# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "clincha/proxmox-ve-8"
  config.vm.box_version = "1.1.0"

  config.vm.synced_folder ".", "/vagrant"

  # config.vm.network "private_network", type: "dhcp"
  config.vm.network "private_network", ip: "192.168.56.10"
  # config.vm.network "public_network", type: "dhcp"

  config.vm.provider "virtualbox" do |vb|
    # vb.cpus = "2"
    vb.cpus = "4"
    # vb.memory = "2048"
    # vb.memory = "4096"
    vb.memory = "8192"

    # ネスト化された仮想化を有効にする
    vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]

    # プロミスキャスモードを許可
    vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
  end
end
