FROM runpod/pytorch:1.0.2-cu1281-torch280-ubuntu2404

ARG S6_OVERLAY_VERSION=3.2.2.0

RUN apt-get update && apt-get install -y nginx curl xz-utils

RUN curl -fsSL https://ollama.com/install.sh | sh

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

COPY s6-rc.d /etc/s6-overlay/s6-rc.d/
COPY nginx.conf /etc/nginx/sites-available/default

ENTRYPOINT ["/init"]