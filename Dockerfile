# syntax=docker/dockerfile:1.7

# ── Client deps ─────────────────────────────────────────────────────────────
FROM node:24-bookworm-slim AS ClientDeps
WORKDIR /app

RUN corepack enable && corepack prepare pnpm@11.22.0 --activate

COPY pnpm-workspace.yaml package.json pnpm-lock.yaml ./
COPY client/package.json ./client/

RUN --mount=type=cache,target=/root/.local/share/pnpm/store \
    pnpm install --frozen-lockfile

# ── Client build ─────────────────────────────────────────────────────────────
FROM ClientDeps AS ClientBuild

COPY client/ ./client/

RUN pnpm --filter client build

# ── Rust deps (cached independently from source changes) ────────────────────
FROM rust:1-bookworm AS RustDeps
WORKDIR /data/project

COPY Cargo.lock Cargo.toml ./
COPY server/Cargo.toml ./server/
COPY agent/Cargo.toml  ./agent/
COPY shared/Cargo.toml ./shared/

# Stub sources so cargo can resolve and fetch the full dependency graph
RUN mkdir -p server/src agent/src shared/src \
    && printf 'fn main(){}' > server/src/main.rs \
    && printf 'fn main(){}' > agent/src/main.rs \
    && printf ''            > shared/src/lib.rs

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    cargo fetch

# ── Rust compile ────────────────────────────────────────────────────────────
FROM RustDeps AS RustBuild

COPY server/ ./server/
COPY agent/  ./agent/
COPY shared/ ./shared/

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    --mount=type=cache,target=/data/project/target \
    cargo build --release --workspace --bins \
    && cp target/release/server /server \
    && cp target/release/agent  /agent

# ── Runtime ─────────────────────────────────────────────────────────────────
FROM docker.io/mbround18/steamcmd:latest

ENV TZ=America/Los_Angeles

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone \
    && apt-get update \
    && apt-get install -y --no-install-recommends curl sudo ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/steam/ark-manager-web/dist \
    && mkdir -p /home/steam/ARK \
    && echo "steam ALL=(ALL) NOPASSWD: /root.sh" > /etc/sudoers.d/steam

COPY --from=RustBuild /server /home/steam/ark-manager-web/server
COPY --from=RustBuild /agent  /home/steam/ark-manager-web/agent
COPY --from=ClientBuild /app/client/dist /home/steam/ark-manager-web/dist
COPY scripts/entrypoint.sh /entrypoint.sh
COPY scripts/root.sh       /root.sh

RUN chmod +x /entrypoint.sh /root.sh \
    && chown -R steam:steam /home/steam

USER steam

ENV HOME=/home/steam
ENV APP_ID=376030
ENV INSTALL_PATH=/home/steam/ARK
ENV EXECUTABLE=./ShooterGame/Binaries/Linux/ShooterGameServer
ENV NAME="ARK Server"
ENV LAUNCH_MODE=native

WORKDIR /home/steam

EXPOSE 8000
EXPOSE 7777/udp
EXPOSE 7778/udp
EXPOSE 27016/udp
EXPOSE 32330/tcp

VOLUME ["/home/steam/ARK"]

HEALTHCHECK --interval=1m --timeout=5s --start-period=30s --retries=3 \
            CMD curl -sf http://127.0.0.1:8000/heartbeat || exit 1

ENTRYPOINT ["/entrypoint.sh"]
