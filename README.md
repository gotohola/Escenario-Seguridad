sudo ip route del 192.168.100.0/24
sudo ip route add 192.168.100.0/24 via 192.168.252.11

### 5. Verificación

#### Desde el host:

```bash
ping -c 3 192.168.100.2
traceroute 192.168.100.2  # Debe mostrar salto 192.168.100.1
```

### 6. Listar servicios
```bash
sudo nmap -sU -p 389 -Pn 192.168.100.4
```
