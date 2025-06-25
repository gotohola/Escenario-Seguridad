#!/usr/bin/env bash
set -e
sysctl -w net.ipv4.ip_forward=1

LAN_IF=$(ip -o -4 addr show | awk '/192\.168\.100\./ {print $2; exit}')
WAN_IF=$(ip -o -4 addr show | awk '/192\.168\.252\./ {print $2; exit}')

# ---------------------------------------------------------------------------
# 0. Estado inicial limpio
# ---------------------------------------------------------------------------
iptables -F
iptables -t nat -F
iptables -X

# ---------------------------------------------------------------------------
# 1. Políticas por defecto  (“zero-trust”: todo DROP salvo lo explícitamente permitido)
# ---------------------------------------------------------------------------
iptables -P INPUT   DROP
iptables -P FORWARD DROP
iptables -P OUTPUT  ACCEPT     # el propio router puede salir para APT, NTP, etc.

# ---------------------------------------------------------------------------
# 2. Reglas genéricas (INPUT / FORWARD)
# ---------------------------------------------------------------------------
## Mantener conexiones ya establecidas
iptables -A INPUT   -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

## Permitir loopback
iptables -A INPUT -i lo -j ACCEPT

# ---------------------------------------------------------------------------
# 3. Servicios *locales* del router: DNS, DHCP, SNMP-agent y SSH
# ---------------------------------------------------------------------------
## DNS y DHCP ofrecidos por dnsmasq a la LAN
iptables -A INPUT -i "${LAN_IF}" -p udp --dport 53        -j ACCEPT   # DNS
iptables -A INPUT -i "${LAN_IF}" -p udp --dport 67:68     -j ACCEPT   # DHCP

## SNMP-agent (solo accesible desde el *manager* 192.168.100.2)
iptables -A INPUT -i "${LAN_IF}" -p udp --dport 161 -s 192.168.100.2 -j ACCEPT

## Gestión por SSH (solo desde el *manager*)
iptables -A INPUT -i "${LAN_IF}" -p tcp --dport 22  -s 192.168.100.2 -j ACCEPT

# ---------------------------------------------------------------------------
# 4. NAT (SNAT/MASQUERADE) para que la LAN tenga salida a Internet
# ---------------------------------------------------------------------------
iptables -t nat -A POSTROUTING -s 192.168.100.0/24 -j MASQUERADE
iptables -A FORWARD -i "${LAN_IF}" -s 192.168.100.0/24 -j ACCEPT
# ---------------------------------------------------------------------------
# 5. LDAP  ➜  servicio puramente interno
# ---------------------------------------------------------------------------
## Autenticación desde cualquier host de la LAN al contenedor ldap (192.168.100.4)
iptables -A FORWARD -i "${LAN_IF}" -o "${LAN_IF}" -p tcp -s 192.168.100.0/24 \
        -d 192.168.100.4 --dport 389 -j ACCEPT
# (no creamos la regla inversa porque el estado ESTABLISHED la cubr


# ---------------------------------------------------------------------------
# 6. VoIP (SIP + RTP) – acceso LAN y red remota 192.168.252.0/24
# ---------------------------------------------------------------------------
## 6.1 Tráfico SIP/RTP procedente de la **LAN**
iptables -A FORWARD -i "${LAN_IF}" -o "${LAN_IF}" -p udp \
        -d 192.168.100.3 --dport 5060 -j ACCEPT
iptables -A FORWARD -i "${LAN_IF}" -o "${LAN_IF}" -p udp \
        -d 192.168.100.3 --dport 10000:20000 -j ACCEPT

## 6.2 Tráfico SIP/RTP procedente de la **sede remota**
iptables -A FORWARD -i "${WAN_IF}" -o "${LAN_IF}" -p udp -s 192.168.252.0/24 \
        -d 192.168.100.3 --dport 5060 -j ACCEPT

iptables -A FORWARD -i "${WAN_IF}" -o "${LAN_IF}" -p udp -s 192.168.252.0/24 \
        -d 192.168.100.3 --dport 10000:20000 -j ACCEPT

### 6.3  DNAT (port-forward) para permitir que la sede remota marque
##      al “router externo” y éste reenvíe al contenedor VoIP.
##      Sustituye 203.0.113.10 por la IP pública real del router.
iptables -t nat -A PREROUTING -i "${WAN_IF}" -p udp --dport 5060 \
        -j DNAT --to-destination 192.168.100.3
iptables -t nat -A PREROUTING -i "${WAN_IF}" -p udp --dport 10000:20000 \
        -j DNAT --to-destination 192.168.100.3

# ---------------------------------------------------------------------------
# 7. SSH intra-LAN – sólo el *manager* (192.168.100.2) puede saltar a otros
# --------------------------------------------------------------------------
iptables -A FORWARD -i "${LAN_IF}" -o "${LAN_IF}" -p tcp -s 192.168.100.2 --dport 22 -j ACCEPT



exec dnsmasq -k
