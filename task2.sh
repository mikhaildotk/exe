#!/bin/bash

# Ставим все необходимое
apt install --no-install-recommends qemu-system libvirt-clients libvirt-daemon-system virtinst dnsmasq -y


# Формируем минималистичный конфиг для dnsmasq
# Удаляем старый
rm -rf /etc/dnsmasq.d/dhcp.conf
# Слушаем бридж с нашей VM
echo "interface=br1" > /etc/dnsmasq.d/dhcp.conf
# встроенный DNS не нужен
echo "port=0" >> /etc/dnsmasq.d/dhcp.conf
# Выделяем пул адресов и время аренды
echo "dhcp-range=30.0.0.100,30.0.0.254,255.255.255.0,12h" >> /etc/dnsmasq.d/dhcp.conf
# Зарезервируем адрес 30.0.0.2 за нашей VM
echo "dhcp-host=00:11:22:33:44:55,alpine,30.0.0.2,infinite" >> /etc/dnsmasq.d/dhcp.conf
# Опция 3 - шлюз по умолчанию
echo "dhcp-option=3,30.0.0.1" >> /etc/dnsmasq.d/dhcp.conf
# DNS
echo "dhcp-option=6,8.8.8.8" >> /etc/dnsmasq.d/dhcp.conf
# Логи
echo "log-facility=/var/log/dnsmasq.log" >> /etc/dnsmasq.d/dhcp.conf
echo "log-async" >> /etc/dnsmasq.d/dhcp.conf
echo "log-queries" >> /etc/dnsmasq.d/dhcp.conf
echo "log-dhcp"  >> /etc/dnsmasq.d/dhcp.conf

# Проверяем конфиг и перезапускаем dhcp
dnsmasq --test && systemctl restart dnsmasq

# Загружаем образ/контрольную сумму
cd /var/lib/libvirt/images/
test ! -f ./alpine-virt-3.19.1-x86_64.iso && wget https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/x86_64/alpine-virt-3.19.1-x86_64.iso{.sha256,}
# чекаем образ
sha256sum -c ./alpine-virt-3.19.1-x86_64.iso.sha256

# Дропаем если vm уже крутится
virsh -q destroy alpine
virsh -q undefine alpine
# Стартуем и грузимся
virt-install \
	--name alpine \
	--memory 2048 \
	--vcpus 2 \
	--os-variant alpinelinux3.17 \
	--cdrom  /var/lib/libvirt/images/alpine-virt-3.19.1-x86_64.iso \
	--network bridge=br1,model=virtio,mac=00:11:22:33:44:55 \
	--graphics none \
	--quiet \
        --noautoconsole

# Эта команда должна выполнится внутри VM для настройки сети.
# Наверняка существует способ запустить произвольные команды внутри VM при ее старте (-:
echo "Выполнить внутри VM:"
echo "  echo -e \"auto lo\niface lo inet loopback\n\nauto eth0\n\niface eth0 inet dhcp\n    hostname alpine\" >/etc/network/interfaces && rc-service networking restart"

# Консоль VM
virsh console alpine

