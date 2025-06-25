# ── Imagen OpenLDAP mantenida por osixia ──────────────────────────────
FROM osixia/openldap:1.5.0

ENV LDAP_ORGANISATION="Vulnerable Corp" \
    LDAP_DOMAIN="vuln.local" \
    LDAP_ADMIN_PASSWORD="admin"

# 1) Cargamos LDIF de ejemplo
COPY bootstrap.ldif /container/service/slapd/assets/config/bootstrap/ldif/50-bootstrap.ldif

# 2) Wrapper para gateway + DNS
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 3) Sustituimos ENTRYPOINT pero delegamos al original de la imagen
ENTRYPOINT ["/entrypoint.sh"]
