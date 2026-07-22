#!/bin/sh
set -eu

OVERRIDE_FILE="docker-compose.override.yml"

if [ -f .env ]; then
    set -a
    . ./.env
    set +a
fi

if [ -n "${DYNAMIC_PORT:-}" ]; then
    cat > "$OVERRIDE_FILE" <<EOF
services:
  autossh-tunnel:
    ports:
      - "${DYNAMIC_PORT}:${DYNAMIC_PORT}"
EOF
else
    rm -f "$OVERRIDE_FILE"
fi

docker compose up -d --build "$@"
