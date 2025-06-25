#!/usr/bin/env bash
set -e

# Sobrescribe la puerta de enlace por la del router
ip route del default || true
ip route add default via 192.168.100.1

# Ajusta resolv.conf para usar al router como DNS
echo "nameserver 192.168.100.1" > /etc/resolv.conf

# Lanza el comando que el usuario pase (o abre shell)
exec "$@"
