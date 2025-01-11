FROM node:20-bookworm-slim

WORKDIR /usr/authorizationserver
COPY src/index.mjs       /usr/authorizationserver
COPY package*.json       /usr/authorizationserver

COPY tokens/public.jwk   /usr/authorizationserver
COPY certs/ssl.key       /usr/authorizationserver
COPY certs/ssl.crt       /usr/authorizationserver

RUN npm install

RUN groupadd --gid 10000 authorizationserver \
  && useradd --uid 10001 --gid authorizationserver --shell /bin/bash --create-home authorizationserver
USER 10001

CMD ["node", "index.mjs"]
