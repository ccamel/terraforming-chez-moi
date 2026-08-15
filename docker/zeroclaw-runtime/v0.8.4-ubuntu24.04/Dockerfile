ARG ZEROCLAW_BASE_NODE=node:24-bookworm-slim@sha256:235600a8101ab264e117b1768e925532262668dc9b581ef1dd7d96ced463b8e7
ARG ZEROCLAW_BASE_RUST_SLIM=rust:1.96-slim@sha256:31ee7fc65186be7e0e0ccb3f2ca305f14e4739e7642a1ae65753aa5d7b874523

# Build the dashboard with ZeroClaw's generator
FROM --platform=$BUILDPLATFORM ${ZEROCLAW_BASE_NODE} AS web-node

FROM --platform=$BUILDPLATFORM ${ZEROCLAW_BASE_RUST_SLIM} AS web-builder

WORKDIR /tmp/zeroclaw

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    g++ \
    git \
    pkg-config \
  && ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
  && ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
  && rm -rf /var/lib/apt/lists/*

COPY --from=web-node /usr/local/bin/node /usr/local/bin/node
COPY --from=web-node /usr/local/lib/node_modules /usr/local/lib/node_modules

ARG ZEROCLAW_VERSION=v0.8.4

RUN set -eux; \
  git clone --depth 1 --branch ${ZEROCLAW_VERSION} https://github.com/zeroclaw-labs/zeroclaw.git .; \
  cd web; \
  npm ci --ignore-scripts; \
  cd ..; \
  cargo web build

# Download the target-platform binary separately
FROM ubuntu:24.04 AS binary-builder

ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETARCH
ARG TARGETVARIANT
ARG ZEROCLAW_VERSION=v0.8.4

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    tar \
    xz-utils \
  && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
  case "${TARGETARCH}${TARGETVARIANT:+/${TARGETVARIANT}}" in \
    amd64) target="x86_64-unknown-linux-gnu" ;; \
    arm64) target="aarch64-unknown-linux-gnu" ;; \
    arm/v7) target="armv7-unknown-linux-gnueabihf" ;; \
    *) echo "Unsupported TARGETARCH/TARGETVARIANT: ${TARGETARCH}${TARGETVARIANT:+/${TARGETVARIANT}}" >&2; exit 1 ;; \
  esac; \
  asset="zeroclaw-${target}.tar.gz"; \
  release_base="https://github.com/zeroclaw-labs/zeroclaw/releases/download/${ZEROCLAW_VERSION}"; \
  workdir="$(mktemp -d)"; \
  trap 'rm -rf "${workdir}"' EXIT; \
  curl -fsSL -o "${workdir}/${asset}" "${release_base}/${asset}"; \
  curl -fsSL -o "${workdir}/SHA256SUMS" "${release_base}/SHA256SUMS"; \
  cd "${workdir}"; \
  grep "  ${asset}$" SHA256SUMS | sha256sum -c -; \
  tar -xzf "${asset}"; \
  install -m 0755 "$(find "${workdir}" -type f -name zeroclaw | head -n 1)" /usr/local/bin/zeroclaw

# Final runtime image
FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    dnsutils \
    file \
    git \
    iproute2 \
    iputils-ping \
    jq \
    less \
    lsof \
    netcat-openbsd \
    openssh-client \
    procps \
    psmisc \
    python3 \
    python3-pip \
    python3-venv \
    rsync \
    tar \
    unzip \
    vim-tiny \
    xz-utils \
  && rm -rf /var/lib/apt/lists/*

COPY --from=binary-builder /usr/local/bin/zeroclaw /usr/local/bin/zeroclaw
COPY --from=web-builder /tmp/zeroclaw/web/dist /usr/local/share/zeroclaw/web

ENV HOME=/root

CMD ["zeroclaw", "daemon", "--host", "0.0.0.0", "--port", "42617"]
