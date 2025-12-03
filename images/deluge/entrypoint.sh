#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR=${DELUGE_CONFIG_PATH:-/var/lib/deluge}
LOGLEVEL=${DELUGE_LOGLEVEL:-info}

mkdir -p "${CONFIG_DIR}"

# Start the Deluge daemon in the background so the web UI can connect to it.
deluged --config "${CONFIG_DIR}" --loglevel "${LOGLEVEL}" -d &

# If the user overrides the CMD, still pass the config directory through.
if [[ ${1:-} == "deluge-web" ]]; then
  if [[ " $* " != *" --config "* ]]; then
    set -- "$@" --config "${CONFIG_DIR}"
  fi
  exec "$@"
fi

exec "$@"
