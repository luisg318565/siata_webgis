FROM python:3.13-slim

RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /scripts
COPY publicar.sh .
COPY coberturas.sld .
RUN chmod +x publicar.sh

ENTRYPOINT ["sh", "/scripts/publicar.sh"]