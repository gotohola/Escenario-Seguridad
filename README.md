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

---

## Documentación de módulos

### 1. Router
Nodo central que conecta dos redes (wifi_net y ext_net). Actúa como firewall y punto de control de tráfico. Permite modificar rutas y reglas de red, simulando un entorno real de administración y seguridad.

### 2. Client
Nodo cliente conectado a la red interna (wifi_net). Se utiliza para realizar pruebas de conectividad, acceso a servicios y simulación de usuarios finales.

### 3. VoIP
Nodo que simula un servidor VoIP (Asterisk). Permite probar servicios de telefonía IP, autenticación básica y comunicación entre nodos. Su configuración es mínima y está pensada para pruebas funcionales simples.

### 4. LDAP
Nodo que simula un servidor LDAP. Permite realizar pruebas de autenticación y gestión de usuarios. Incluye scripts de inicialización y reglas de firewall básicas. Su importancia es secundaria en el escenario, pero útil para pruebas de acceso y seguridad.

---

## Interconexión de módulos

- Todos los nodos están conectados a la red interna `wifi_net` (subred 192.168.100.0/24), con el router como gateway principal (192.168.100.1).
- El router también está conectado a la red externa `ext_net` (subred 192.168.252.0/24), permitiendo la salida y entrada de tráfico entre redes.
- El cliente, VoIP y LDAP sólo tienen acceso directo a la red interna, y dependen del router para comunicarse con el exterior.
- El router puede aplicar reglas de firewall, NAT y routing para controlar el tráfico entre los nodos y hacia el exterior.

---

## Pruebas de ciberseguridad posibles

- **Pruebas de firewall y routing:** Verificar el aislamiento de redes, reglas de acceso y manipulación de rutas.
- **Escaneo de servicios:** Usar herramientas como nmap para detectar servicios expuestos (por ejemplo, LDAP en el puerto 389).
- **Ataques de fuerza bruta:** Simular intentos de acceso no autorizado a los servicios LDAP y VoIP.
- **Pruebas de autenticación:** Validar la robustez de los mecanismos de autenticación en LDAP y VoIP.
- **Simulación de ataques internos:** Probar la capacidad de los nodos para resistir ataques desde la red interna (por ejemplo, spoofing, ARP poisoning).
- **Pruebas de DoS:** Simular ataques de denegación de servicio contra los servicios expuestos.
- **Auditoría de logs y tráfico:** Analizar los registros y el tráfico para detectar intentos de intrusión o anomalías.

---
