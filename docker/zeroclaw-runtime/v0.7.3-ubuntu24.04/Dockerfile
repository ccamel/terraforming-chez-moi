FROM ubuntu:24.04 AS builder

ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETARCH
ARG TARGETVARIANT
ARG ZEROCLAW_VERSION=v0.7.3

# Install Node.js for web dashboard build
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    tar \
    xz-utils \
  && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get install -y nodejs \
  && rm -rf /var/lib/apt/lists/*

# Download and build web dashboard
RUN set -eux; \
  git clone --depth 1 --branch ${ZEROCLAW_VERSION} https://github.com/zeroclaw-labs/zeroclaw.git /tmp/zeroclaw; \
  cd /tmp/zeroclaw/web; \
  npm ci --production=false; \
  npm run build

# Download zeroclaw binary
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

# Copy zeroclaw binary and web dashboard from builder
COPY --from=builder /usr/local/bin/zeroclaw /usr/local/bin/zeroclaw
COPY --from=builder /tmp/zeroclaw/web/dist /usr/local/share/zeroclaw/web

ENV HOME=/root

CMD ["zeroclaw", "daemon", "--host", "0.0.0.0", "--port", "42617"]
