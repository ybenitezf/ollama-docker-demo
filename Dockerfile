FROM runpod/pytorch:1.0.2-cu1281-torch280-ubuntu2404

RUN apt-get update && apt-get install -y nginx curl supervisor gettext-base && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://ollama.com/install.sh | sh

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY prepare.sh /prepare.sh

EXPOSE 8080

ENTRYPOINT ["/prepare.sh"]