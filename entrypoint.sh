#!/bin/sh

TUNNEL_ARGS=""

# ローカルフォワード (-L): コンテナのポートをリモート経由で指定ホスト:ポートに接続
# 形式: ローカルポート:転送先ホスト:転送先ポート
if [ -n "${LOCAL_TUNNELS}" ]; then
    for tunnel in $(echo "${LOCAL_TUNNELS}" | tr ',' ' '); do
        echo "Adding local forward:   -L ${tunnel}"
        TUNNEL_ARGS="${TUNNEL_ARGS} -L ${tunnel}"
    done
fi

# リモートフォワード (-R): リモートのポートをローカルに引き込む
# 形式: リモートポート:転送先ホスト:転送先ポート
if [ -n "${REMOTE_TUNNELS}" ]; then
    for tunnel in $(echo "${REMOTE_TUNNELS}" | tr ',' ' '); do
        echo "Adding remote forward:  -R ${tunnel}"
        TUNNEL_ARGS="${TUNNEL_ARGS} -R ${tunnel}"
    done
fi

# ダイナミックフォワード (-D): SOCKSプロキシ
if [ -n "${DYNAMIC_PORT}" ]; then
    PROXY_ADDRESS="0.0.0.0:${DYNAMIC_PORT}"
    echo "Adding dynamic forward: -D ${PROXY_ADDRESS}"
    TUNNEL_ARGS="${TUNNEL_ARGS} -D ${PROXY_ADDRESS}"
fi

AUTOSSH_COMMON_OPTS="\
     -M 0 \
     -N \
     -o ServerAliveInterval=30 \
     -o ServerAliveCountMax=3 \
     -o ExitOnForwardFailure=yes \
     -o StrictHostKeyChecking=yes \
     -o UserKnownHostsFile=/root/.ssh/known_hosts \
     -p ${SSH_PORT} \
     -i ${SSH_KEY_PATH} \
     ${SSH_USER}@${SSH_HOST}"

exec autossh \
     ${TUNNEL_ARGS} \
     ${AUTOSSH_COMMON_OPTS}
