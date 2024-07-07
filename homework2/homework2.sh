#!/bin/bash

# Рабочий каталог
WORKDIR="devops_homework"

# На всякий случай приведем пути к абсолютному виду
MKWORKDIR=$(readlink -f ${WORKDIR})

# Проверим/создадим
test ! -d ${MKWORKDIR} && mkdir ${MKWORKDIR} || echo "${MKWORKDIR} already exists!"
