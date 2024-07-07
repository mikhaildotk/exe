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
touch ${MKWORKDIR}/shared_file.txt chmod 660 ${MKWORKDIR}/shared_file.txt

# Сменим владельца и группу
chown devops_user:devops_group ${MKWORKDIR}/shared_file.txt

#---#
# 3 #
#---#---------------------------------------------
