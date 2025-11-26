FROM ghcr.io/takahiro-kawaguchi/autossh-jump-base:main

COPY entrypoint-dynamic.sh /entrypoint-dynamic.sh
RUN chmod +x /entrypoint-dynamic.sh

CMD ["/entrypoint-dynamic.sh"]