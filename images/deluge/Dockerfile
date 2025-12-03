FROM debian:bookworm-slim

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt/lists \
    set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      ca-certificates \
      python3 \
      python3-gi \
      python3-libtorrent \
      deluged \
      deluge-web \
      deluge-console; \
    rm -rf /var/lib/apt/lists/*

RUN useradd --system --shell /usr/sbin/nologin deluge

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER deluge

EXPOSE 8112 58846 58946

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["deluge-web", "-d"]
