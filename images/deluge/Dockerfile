FROM debian:bookworm-slim

ARG DELUGE_VERSION

ENV DELUGE_CONFIG_PATH=/var/lib/deluge \
    DELUGE_LOGLEVEL=info \
    PATH=/home/deluge/.local/bin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    PIP_BREAK_SYSTEM_PACKAGES=1 \
    PIP_NO_BINARY=:all:

RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      ca-certificates \
      python3 \
      python3-pip \
      python3-gi \
      python3-libtorrent \
      python3-dev \
      build-essential \
      rustc \
      cargo \
      libssl-dev \
      libffi-dev; \
    pip3 install --no-cache-dir "deluge==${DELUGE_VERSION}"; \
    apt-get purge -y --auto-remove \
      build-essential \
      python3-dev \
      rustc \
      cargo \
      libssl-dev \
      libffi-dev; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    useradd --system --home "${DELUGE_CONFIG_PATH}" --shell /usr/sbin/nologin deluge; \
    mkdir -p "${DELUGE_CONFIG_PATH}"/config "${DELUGE_CONFIG_PATH}"/downloads; \
    chown -R deluge:deluge "${DELUGE_CONFIG_PATH}"

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER deluge
WORKDIR ${DELUGE_CONFIG_PATH}

VOLUME ["${DELUGE_CONFIG_PATH}"]
EXPOSE 8112 58846 58946

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["deluge-web", "-d"]
