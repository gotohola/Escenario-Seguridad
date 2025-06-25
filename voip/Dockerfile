FROM andrius/asterisk:latest

# Copiar configuración mínima
COPY config /etc/asterisk

# Agregar wrapper de red y arranque
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 5060/udp 5060/tcp 10000-20000/udp
