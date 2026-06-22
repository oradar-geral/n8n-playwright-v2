ARG NODE_VERSION=20

FROM node:${NODE_VERSION}-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_ENV=production
ENV N8N_RELEASE_TYPE=stable

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        openssh-client \
        graphicsmagick \
        tini \
        ca-certificates \
        wget \
        curl \
        tzdata \
        fontconfig \
        openssl && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g --omit=dev n8n --ignore-scripts && \
    npm rebuild --prefix=/usr/local/lib/node_modules/n8n sqlite3 && \
    rm -rf /root/.npm

RUN npx playwright install-deps chromium && \
    npx playwright install chromium

ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
ENV PLAYWRIGHT_BROWSERS_PATH=/root/.cache/ms-playwright

RUN mkdir -p /home/node/.n8n && \
    chmod -R 777 /home/node/.n8n && \
    chown -R node:node /home/node && \
    chown -R node:node /root/.cache/ms-playwright || true

WORKDIR /home/node

USER node

EXPOSE 5678

ENTRYPOINT ["tini", "--", "n8n"]
