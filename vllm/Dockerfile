FROM runpod/pytorch:1.0.2-cu1281-torch280-ubuntu2404

RUN pip install --no-cache-dir vllm && pip cache purge

COPY prepare.sh /prepare.sh
RUN chmod +x /prepare.sh

EXPOSE 8000

ENTRYPOINT ["/prepare.sh"]
