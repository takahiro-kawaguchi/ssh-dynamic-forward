#!/bin/sh

# 環境変数
DYNAMIC_PORT=${DYNAMIC_PORT:-1080}
PROXY_ADDRESS="0.0.0.0:${DYNAMIC_PORT}" 

echo "Starting autossh dynamic tunnel: ${PROXY_ADDRESS} <- Remote (SOCKS Proxy)"

# 共通オプションの定義
AUTOSSH_COMMON_OPTS="\
     -M 0 \
     -N \
     -o ServerAliveInterval=30 \
     -o ServerAliveCountMax=3 \
     -o ExitOnForwardFailure=yes \
     -o StrictHostKeyChecking=yes \
     -o UserKnownHostsFile=${KNOWN_HOSTS_PATH} \
     -p ${SSH_PORT} \
     -i ${SSH_KEY_PATH} \
     ${SSH_USER}@${SSH_HOST}"
     
# ダイナミックフォワードオプションのみを実行 (execで置き換え)
exec autossh \
     -D "${PROXY_ADDRESS}" \
     ${AUTOSSH_COMMON_OPTS}