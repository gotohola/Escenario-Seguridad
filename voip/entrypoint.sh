#!/bin/sh
set -e

# 1) Forzamos gateway y DNS
ip route del default || true
ip route add default via 192.168.100.1
echo "nameserver 192.168.100.1" > /etc/resolv.conf

# 2) Lanzamos Asterisk directamente
exec asterisk -f -U asterisk
