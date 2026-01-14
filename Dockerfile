# Node.js LTS terbaru (Active LTS saat Jan 2026: v24)
FROM node:24-alpine

WORKDIR /app

ENV NODE_ENV=production

# Paket runtime yang dibutuhkan untuk download + ekstrak binary
# + tini untuk signal forwarding (graceful shutdown)
RUN apk add --no-cache \
    ca-certificates \
    curl \
    wget \
    unzip \
    tar \
    openssl \
    bash \
    coreutils \
    iproute2 \
    tini

# Install deps (gunakan package-lock kalau ada)
COPY package.json ./
# Kalau kamu punya package-lock.json, lebih bagus:
# COPY package-lock.json ./
# RUN npm ci --omit=dev
RUN npm install --omit=dev

# Copy source
COPY . .

# Pastikan writable workspace (defaultnya pakai /tmp)
RUN mkdir -p /tmp/nodejs-paas-proxy

EXPOSE 3000

# Healthcheck (endpoint /health)
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD wget -qO- http://127.0.0.1:${PORT:-3000}/health || exit 1

# Tini sebagai init
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "index.js"]
