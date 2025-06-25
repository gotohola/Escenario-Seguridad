#!/usr/bin/env bash
set -e

# 0) Políticas por defecto
iptables -F
iptables -P INPUT  DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD DROP

# 1) Estado
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# 2) Servicio SIP UDP 5060  (LAN + sede remota)
iptables -A INPUT -p udp --dport 5060 \
        -s 192.168.100.0/24 -j ACCEPT
iptables -A INPUT -p udp --dport 5060 \
        -s 192.168.252.0/24 -j ACCEPT

# 3) RTP UDP 10000-20000 (audio)
iptables -A INPUT -p udp --dport 10000:20000 \
        -s 192.168.100.0/24 -j ACCEPT
iptables -A INPUT -p udp --dport 10000:20000 \
        -s 192.168.252.0/24 -j ACCEPT

# 4) Gestión por SSH solo desde el *manager*
iptables -A INPUT -p tcp --dport 22 -s 192.168.100.2 -j ACCEPT

# 5) (opcional) limitar scans
iptables -A INPUT -p udp --dport 5060 -m limit --limit 10/min --limit-burst 20 \
        -j ACCEPT
