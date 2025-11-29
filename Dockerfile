FROM debian:stable-slim

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    openssh-client \
    autossh \
    rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# コンテナ起動時にスクリプトを実行
ENTRYPOINT ["/entrypoint.sh"]
