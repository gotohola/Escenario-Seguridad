#!/usr/bin/env bash
set -e

# —— 1) Fijamos gateway + DNS
ip route del default || true
ip route add default via 192.168.100.1
echo "nameserver 192.168.100.1" > /etc/resolv.conf

# —— 2) Lanzamos el ENTRYPOINT original de osixia/openldap
exec /container/tool/run "$@"
