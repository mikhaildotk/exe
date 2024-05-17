#!/bin/bash

# Ставим все необходимое
sudo apt-get install libvirt-clients libvirt-daemon-system qemu-kvm bridge-utils dnsmasq -y

# пользователя sysop в группу libvirt для управления
sudo usermod -a -G libvirt sysop

# Раскоментируме uri_default = "qemu:///system"
sudo sed -i '/uri_default/s/^#//g' /etc/libvirt/libvirt.conf
