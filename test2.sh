#!/bin/bash

#
virsh --connect qemu:///system list
virsh destroy alpine

# Ставим все необходимое
apt install --no-install-recommends qemu-system libvirt-clients libvirt-daemon-system virtinst dnsmasq -y



# Удаляем старый
rm -rf /etc/dnsmasq.d/dhcp.conf
echo "interface=br1" > /etc/dnsmasq.d/dhcp.conf
# To disable dnsmasq's DNS server functionality.
echo "port=0" >> /etc/dnsmasq.d/dhcp.conf
# To enable dnsmasq's DHCP server functionality.
echo "dhcp-range=30.0.0.100,30.0.0.254,255.255.255.0,12h" >> /etc/dnsmasq.d/dhcp.conf
# Set static IPs of other PCs and the Router.
echo "dhcp-host=00:11:22:33:44:55,alpine,30.0.0.2,infinite" >> /etc/dnsmasq.d/dhcp.conf
# Set gateway as Router. Following two lines are identical.
#dhcp-option=option:router,192.168.0.1
echo "dhcp-option=3,30.0.0.1" >> /etc/dnsmasq.d/dhcp.conf
# Set DNS server as Router.
echo "dhcp-option=6,8.8.8.8" >> /etc/dnsmasq.d/dhcp.conf
# Logging.
echo "log-facility=/var/log/dnsmasq.log" >> /etc/dnsmasq.d/dhcp.conf
echo "log-async" >> /etc/dnsmasq.d/dhcp.conf
echo "log-queries" >> /etc/dnsmasq.d/dhcp.conf
echo "log-dhcp"  >> /etc/dnsmasq.d/dhcp.conf

# Проверяем конфиг и перезапускаем dhcp
dnsmasq --test && systemctl restart dnsmasq

# Раскоментируме uri_default = "qemu:///system"
sed -i '/^#uri_default/s/^#//g' /etc/libvirt/libvirt.conf

# Загружаем образ контрольную сумму
test ! -f /var/lib/libvirt/images/alpine-virt-3.19.1-x86_64.iso && curl https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/x86_64/alpine-virt-3.19.1-x86_64.iso --output /var/lib/libvirt/images/alpine-virt-3.19.1-x86_64.iso
test ! -f /var/lib/libvirt/images/alpine-virt-3.19.1-x86_64.iso.sha256 && curl https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/x86_64/alpine-virt-3.19.1-x86_64.iso.sha256 --output /var/lib/libvirt/images/alpine-virt-3.19.1-x86_64.iso.sha256
# чекаем образ
cd /var/lib/libvirt/images && sha256sum -c /var/lib/libvirt/images/alpine-virt-3.19.1-x86_64.iso.sha256

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
	--network bridge=br1,model=e1000,mac=00:11:22:33:44:55 \
	--graphics none

# Внутри фдзшту
echo -e "auto eth0\niface eth0 inet dhcp\n  udhcpc_opts -O search\n" >/etc/network/interfaces && rc-service networking restart
