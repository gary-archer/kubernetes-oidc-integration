FROM node:20-bookworm-slim

WORKDIR /usr/authorizationserver
COPY src/index.mjs                   /usr/authorizationserver/
COPY token-signing-keys/public.jwk   /usr/authorizationserver/token-signing-keys/
COPY package*.json                   /usr/authorizationserver/
RUN npm install

RUN groupadd --gid 10000 authorizationserver \
  && useradd --uid 10001 --gid authorizationserver --shell /bin/bash --create-home authorizationserver
USER 10001

CMD ["node", "index.mjs"]
