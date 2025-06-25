# router/Dockerfile
FROM ciscotalos/snort3:latest

USER root
ENV PATH="/home/snorty/snort3/bin:${PATH}"

RUN apt-get -o Acquire::AllowInsecureRepositories=true \
            -o Acquire::Check-Valid-Until=false \
            -o Acquire::AllowReleaseInfoChange::Suite=true \
            update && \
    apt-get install -y iptables iproute2 dnsmasq && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY dnsmasq.conf /etc/dnsmasq.conf
COPY start.sh     /start.sh
RUN chmod +x /start.sh

ENTRYPOINT ["/start.sh"]
