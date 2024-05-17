#!/bin/bash

# Дропаем нэймспэйсы и интерфейсы
ip netns del h2 > /dev/null 2>&1
ip netns del h3 > /dev/null 2>&1
ip netns del h4 > /dev/null 2>&1
ip link del veth-h2-out > /dev/null 2>&1
ip link del veth-h3-out > /dev/null 2>&1
ip link del veth-h4-out > /dev/null 2>&1
ip link del br0 > /dev/null 2>&1
ip link del br1 > /dev/null 2>&1
ip link del dummy0 > /dev/null 2>&1

# echo 1 > /proc/sys/net/ipv4/ip_forward                  # Разрешаем пересылку пакетов
# iptables -t nat -A POSTROUTING -o $IF -j MASQUERADE     # Тут бы по хорошему, включть маскарадинг на интерфейсе $IF, имеющий доступ к сети интернет, что позволит выходить в нее из подсетей в неймспейсах

## h2 ---->
ip netns add h2                                           # Добавляем нэймспэйс
ip link add veth-h2-in type veth peer name veth-h2-out    # Добавляем виртуальный кабель (*-in - внутри простраства/ *-out - снаружи
ip link set veth-h2-in netns h2                           # один его линк аттачим в нэймспэйс h2
ip netns exec h2 ip link set dev veth-h2-in up            # поднимем родительский интерфейс для вилан (аплинк в дефолтный нэймспэйс)
ip netns exec h2 ip link set dev lo up                    # на всякий лупбэк поднимем (-;

ip netns exec h2 ip link add link veth-h2-in name veth-h2-in.10 type vlan id 10 # Создаем в контексте неймспэйса h2 интерфейс вилан с тэгом 10 на родительском veth-h2-in
  ip netns exec h2 ip addr add 10.0.0.2/24 brd 10.0.0.255 dev veth-h2-in.10     # Назначаем ему ipv4 адресс 10.0.0.2
    ip netns exec h2 ip link set dev veth-h2-in.10 up				                    # Поднимем его
      ip netns exec h2 ip route add default via 10.0.0.1 dev veth-h2-in.10      # маршрут по умолчанию через 10.0.0.1

ip netns exec h2 ip link add link veth-h2-in name veth-h2-in.20 type vlan id 20 # Создаем в контексте неймспэйса h2 интерфейс вилан с тэгом 20 на родительском veth-h2-in
  ip netns exec h2 ip addr add 20.0.0.2/24 brd 20.0.0.255 dev veth-h2-in.20     # Назначаем ему ipv4 адресс 20.0.0.2
    ip netns exec h2 ip link set dev veth-h2-in.20 up				                    # Поднимем его

## h3 ---->
ip netns add h3                                           # Добавляем нэймспэйс
ip link add veth-h3-in type veth peer name veth-h3-out    # Добавляем виртуальный кабель (*-in - внутри простраства/ *-out - снаружи
ip link set veth-h3-in netns h3                           # один его линк аттачим в нэймспэйс h3
ip netns exec h3 ip link set dev veth-h3-in up            # поднимем родительский интерфейс для вилан (аплинк в дефолтный нэймспэйс)
ip netns exec h3 ip link set dev lo up                    # на всякий лупбэк поднимем (-;

ip netns exec h3 ip link add link veth-h3-in name veth-h3-in.10 type vlan id 10 # Создаем в контексте неймспэйса h2 интерфейс вилан с тэгом 10 на родительском veth-h2-in
  ip netns exec h3 ip addr add 10.0.0.3/24 brd 10.0.0.255 dev veth-h3-in.10     # Назначаем ему ipv4 адресс 10.0.0.3
    ip netns exec h3 ip link set dev veth-h3-in.10 up				                    # Поднимем его
      ip netns exec h3 ip route add default via 10.0.0.1 dev veth-h3-in.10      # маршрут по умолчанию через 10.0.0.1 (если в другие подсети захотим)

## h4 ---->
ip netns add h4                                           # Добавляем нэймспэйс
ip link add veth-h4-in type veth peer name veth-h4-out    # Добавляем виртуальный кабель (*-in - внутри простраства/ *-out - снаружи
ip link set veth-h4-in netns h4                           # один его линк аттачим в нэймспэйс h4
ip netns exec h4 ip link set dev veth-h4-in up            # поднимем родительский интерфейс для вилан  (аплинк в дефолтный нэймспэйс)
ip netns exec h4 ip link set dev lo up                    # на всякий лупбэк поднимем (-;

ip netns exec h4 ip link add link veth-h4-in name veth-h4-in.20 type vlan id 20 # Создаем в контексте неймспэйса h4 интерфейс вилан с тэгом 20 на родительском veth-h4-in
  ip netns exec h4 ip addr add 20.0.0.4/24 brd 20.0.0.255 dev veth-h4-in.20     # Назначаем ему ipv4 адресс 20.0.0.4
    ip netns exec h4 ip link set dev veth-h4-in.20 up				                    # Поднимем его
      ip netns exec h4 ip route add default via 20.0.0.1 dev veth-h4-in.20      # маршрут по умолчанию через 20.0.0.1 (если в другие подсети захотим)

## Добавляем мост и даунлинки в него
ip link add name br0 type bridge                           # создадим мост
ip link set dev br0 up                                     # поднимем его
ip link set dev veth-h2-out master br0                     # Добавляем даунлинк до h2 в мост br0
ip link set dev veth-h3-out master br0                     #                    до h3 в мост br0
ip link set dev veth-h4-out master br0                     #                    до h4 в мост br0

ip link set dev veth-h2-out up                            # поднимем даунлинк в h2
ip link set dev veth-h3-out up                            #                     h3
ip link set dev veth-h4-out up                            #                     h4

### Вешаем адреса на мост
ip link add name br0.10 link br0 type vlan id 10          # Добавим интерфейс с тэгом 10
  ip addr add 10.0.0.1/24 broadcast 10.0.0.255 dev br0.10 # назначим ipv4 адреc
    ip link set br0.10 up                                 # поднимем его

ip link add name br0.20 link br0 type vlan id 20          # Добавим интерфейс с тэгом 10
  ip addr add 20.0.0.1/24 broadcast 20.0.0.255 dev br0.20 # назначим ipv4 адреc
    ip link set br0.20 up                                 # поднимем его

## Для отладки
for i in h2 h3 h4; do
  echo "--- пространство имен $i ---"
  echo "Интерфейсы:"
  ip netns exec $i ip -4 -br addr show scope global
  echo "Маршруты:"
  ip netns exec $i ip -4 -br route show scope global
  echo -e "\n"
done

# Проверяем, что хост-система (относительно неймспэйсов) имеет доступ к подсетям в нэймспейсах
ping -c1 -W1 -I br0.10 10.0.0.2 > /dev/null 2>&1 && echo "10.0.0.1 <icmp> 10.0.0.2 - OK" || echo "10.0.0.1 <icmp> 10.0.0.2 - FAIL"
ping -c1 -W1 -I br0.10 10.0.0.3 > /dev/null 2>&1 && echo "10.0.0.1 <icmp> 10.0.0.3 - OK" || echo "10.0.0.1 <icmp> 10.0.0.3 - FAIL"
ping -c1 -W1 -I br0.20 20.0.0.2 > /dev/null 2>&1 && echo "20.0.0.1 <icmp> 20.0.0.2 - OK" || echo "20.0.0.1 <icmp> 20.0.0.2 - FAIL"
ping -c1 -W1 -I br0.20 20.0.0.2 > /dev/null 2>&1 && echo "20.0.0.1 <icmp> 20.0.0.4 - OK" || echo "20.0.0.1 <icmp> 20.0.0.4 - FAIL"
echo -e "\n"

# Из условия задания, мост br1 в нашей гостевой системе, имеет ipv4 адрес 30.0.0.1/24. Если принять,
# что синим цветом изображена сеть 30.0.0.0/24 гипервизора, к которой 
# подключена наша гостевая система и в которой находится хост с адресом 30.0.0.2/24,
# то тогда действия следующие:

# По идее, нам нужно найти первую, проводную, сетевую карту на шине и уже ее добавить в мост br1,
# но наверное это оверхэд для задания. По этому создадим dummy интерфейс и примем его за "физический", который указан в настиройках
# нашей виртуалки и подключен к сети 30.0.0.0/24 гипервизора. (ну и существующую сеть не поламаем (-;)
ip link add name dummy0 type dummy                         # Имитируем интерфейс ВМ, смотрящий в подсеть 30.0.0.0/24 гипервизора
ip link set dummy0 up                                      # Поднимаем
ip link add name br1 type bridge                           # создадим мост
ip addr add 30.0.0.1/24 brd 30.0.0.255 dev br1		         # Назначим адрес
ip link set dev br1 up                                     # поднимем его
ip link set dev dummy0 master br1                          # Добавим в него наш dummy0

echo "--- default namespace ---"
ip -4 -br addr show scope global
echo -e "\n"

