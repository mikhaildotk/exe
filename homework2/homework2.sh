#!/bin/bash

# Рабочий каталог
WORKDIR="devops_homework"

# На всякий случай приведем пути к абсолютному виду
MKWORKDIR=$(readlink -f ${WORKDIR})

# Проверим/создадим
test ! -d ${MKWORKDIR} && mkdir ${MKWORKDIR} || echo "${MKWORKDIR} already exists!"

# Переходим в созданную директорию
cd ${MKWORKDIR} && echo "Current location is ${MKWORKDIR}"

# Создадим file1.txt, file2.txt, file3.txt
touch file{1..3}.txt

# Добавим в созданные файлы строку "Hello, World!"
for i in file{1..3}.txt; do echo "Hello, World!" > $i; done

# Выполним пункты 5,6,7 задания #1
cp -a file1.txt file1_copy.txt && mv file2.txt ../ && rm file3.txt
