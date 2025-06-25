#!/usr/bin/env bash
set -e

# Limpiar reglas previas
iptables -F
iptables -X

# Políticas por defecto (deny-by-default)
iptables -P INPUT   DROP
iptables -P OUTPUT  DROP
iptables -P FORWARD DROP   # Contenedor no debe rutear

# Permitir conexiones ya establecidas (entrada y salida)
iptables -A INPUT  -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Permitir loopback local (precaución en contenedores)
iptables -A INPUT  -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# LDAP – permitir conexiones solo desde la LAN
iptables -A INPUT -p tcp --dport 389 -s 192.168.100.0/24 -j ACCEPT

# SSH solo desde el administrador (192.168.100.2)
iptables -A INPUT -p tcp --dport 22 -s 192.168.100.2 -j ACCEPT

# DNS – permitir resolución hacia el router
iptables -A OUTPUT -p udp --dport 53 -d 192.168.100.1 -j ACCEPT

# APT (opcional, si haces apt update desde el contenedor)
iptables -A OUTPUT -p tcp --dport 80  -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
