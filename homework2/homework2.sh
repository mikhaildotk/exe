#!/bin/bash

# Рабочий каталог
WORKDIR="devops_homework"

# На всякий случай приведем пути к абсолютному виду
MKWORKDIR=$(readlink -f ${WORKDIR})

# Пользователь
DEVOPS_USER=devops_user
# Группа
DEVOPS_GROUP=devops_group

#---#
# 1 #
#---#---------------------------------------------

# Проверим/создадим
test ! -d ${MKWORKDIR} && mkdir ${MKWORKDIR} || echo "${MKWORKDIR} already exists!"

# Переходим в созданную директорию
cd ${MKWORKDIR} && echo "Current location is ${MKWORKDIR}"

# Создадим file1.txt, file2.txt, file3.txt
touch file{1..3}.txt

# Добавим в созданные файлы строку "Hello, World!"
for i in file{1..3}.txt; do echo "Hello, World!" > $i; done

# Выполним пункты 5,6,7 задания #1
cp -a file1.txt file1_copy.txt && mv ./file2.txt ../ && rm ./file3.txt

#---#
# 2 #
#---#---------------------------------------------

# Для следующих операций, нам нужна эскалация прав
if [ "$(id -u)" -ne 0 ]; then
  echo >&2 "Only root!"
  exit 1
fi

# Пользователь и группа - проверим/создадим
getent passwd ${DEVOPS_USER} > /dev/null 2>&1 && echo "User ${DEVOPS_USER} already exist!" || useradd ${DEVOPS_USER}
getent group ${DEVOPS_GROUP} > /dev/null 2>&1 && echo "Group ${DEVOPS_GROUP} already exist!" || useradd ${DEVOPS_GROUP}

# Пользователя devops_user в группу devops_group
usermod -aG devops_group devops_user

# Элегантнее так
# install --mode=664 --owner=devops_user --group=devops_group /dev/null ${MKWORKDIR}/shared_file.txt

# Создадим файл и установим права
touch ${MKWORKDIR}/shared_file.txt && chmod 660 ${MKWORKDIR}/shared_file.txt

# Сменим владельца и группу
chown devops_user:devops_group ${MKWORKDIR}/shared_file.txt

#---#
# 3 #
#---#---------------------------------------------

# А вдруг нет?
which ifconfig || apt install net-tools -y

#
clear && ifconfig

#
ifconfig ens18:0 192.168.1.123 netmask 255.255.255.0 up

#
ping -c4 google.com

#---#
# 4 #
#---#---------------------------------------------

#
echo y|ssh-keygen -t ed25519 -N "" -C "Devops key root@localhost" -f ${MKWORKDIR}/id_ed25519-devops_homework

#
ssh-copy-id -i ./id_ed25519-devops_homework root@localhost

#
echo -e "# Override 22 port\nPort 4343\n" > /etc/ssh/sshd_config.d/Port.conf
echo -e "# Disable pass auth\nPasswordAuthentication no\n" > /etc/ssh/sshd_config.d/PasswordAuthentication.conf

#
iptables -I INPUT -p tcp --dport 4343 -j ACCEPT

#
sshd -T | egrep -i '^port 4343|passwordauthentication no' && service ssh restart

#---#
# 5 #
#---#---------------------------------------------

#
cat <<EOF > ${MKWORKDIR}/echodatetime.sh
#!/bin/bash
echo $(date '+%H.%M_%d.%m.%Y') | xargs -I timedate echo "touch ${MKWORKDIR}/timedate.txt;echo timedate >> ${MKWORKDIR}/timedate.txt"|sh
EOF
chmod +x ${MKWORKDIR}/echodatetime.sh

#
(crontab -l 2>/dev/null; echo "*/5 * * * * ${MKWORKDIR}/echodatetime.sh") | crontab -

#
cat <<EOF > ${MKWORKDIR}/echodatetime.service
[Unit]
Description=Run echodatetime.sh script

[Service]
Type=simple
ExecStart=${MKWORKDIR}/echodatetime.sh

[Install]
WantedBy=multi-user.target
EOF

#
systemctl link ${MKWORKDIR}/echodatetime.service

#
systemctl enable --now echodatetime
