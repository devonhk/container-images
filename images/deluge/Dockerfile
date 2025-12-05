FROM debian:trixie-slim

RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      ca-certificates \
      python3 \
      deluged \
      deluge-web \
      p7zip-full; \
    rm -rf /var/lib/apt/lists/*

RUN useradd  --uid 911 --system --shell /usr/sbin/nologin deluge

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER deluge

EXPOSE 8112 58846 58946

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["deluge-web", "-d"]
