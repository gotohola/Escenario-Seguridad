#!/usr/bin/env bash
set -e

# 1) Habilita reenvío de paquetes
sysctl -w net.ipv4.ip_forward=1

# 2) Reglas iptables: NAT + permitir forward
iptables -t nat -C POSTROUTING -s 192.168.100.0/24 -j MASQUERADE \
  || iptables -t nat -A POSTROUTING -s 192.168.100.0/24 -j MASQUERADE

iptables -C FORWARD -i eth1 -s 192.168.100.0/24 -j ACCEPT \
  || iptables -A FORWARD -i eth1 -s 192.168.100.0/24 -j ACCEPT

iptables -C FORWARD -o eth1 -d 192.168.100.0/24 -j ACCEPT \
  || iptables -A FORWARD -o eth1 -d 192.168.100.0/24 -j ACCEPT

# 3) Arranca dnsmasq (en foreground para que los logs vayan a stdout)
exec dnsmasq -k
