# Client Build
FROM --platform=linux/amd64 mbround18/ark-manager-client:latest as ClientBuild

# Rust Binaries Build
FROM rust:1.89-bookworm as RustBuild
WORKDIR /data/project
COPY ./Cargo.lock ./Cargo.toml ./
COPY ./server ./server
COPY ./agent ./agent
COPY ./shared ./shared
RUN cargo build --release --workspace --bins

# Runtime
FROM docker.io/mbround18/steamcmd:latest

ENV TZ=America/Los_Angeles

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone \
    && apt-get update \
    && apt-get install -y --no-install-recommends curl sudo ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/steam/ark-manager-web \
    && mkdir -p /home/steam/ARK \
    && mkdir -p /etc/arkmanager \
    && echo "steam ALL=(ALL) NOPASSWD: /root.sh" > /etc/sudoers.d/steam

COPY --from=RustBuild /data/project/target/release/server /home/steam/ark-manager-web/
COPY --from=RustBuild /data/project/target/release/agent /home/steam/ark-manager-web/
COPY --from=ClientBuild /apps/client /home/steam/ark-manager-web/dist
COPY ./scripts/entrypoint.sh /entrypoint.sh
COPY ./scripts/root.sh /root.sh

RUN chmod +x /entrypoint.sh /root.sh \
    && chown -R steam:steam /home/steam \
    && chown -R steam:steam /etc/arkmanager

USER steam

ENV HOME=/home/steam
ENV ARK_MANAGER_CONFIG_DIRECTORY=/etc/arkmanager
ENV ARK_DIRECTORY=/home/steam/ARK
ENV APP_ID=376030
ENV INSTALL_PATH=/home/steam/ARK
ENV EXECUTABLE=./ShooterGame/Binaries/Linux/ShooterGameServer

WORKDIR /home/steam

VOLUME ["/home/steam/ARK", "/etc/arkmanager"]

HEALTHCHECK --interval=1m --timeout=3s \
            CMD curl -f http://127.0.0.1:8000/heartbeat || exit 1

ENTRYPOINT [ "/entrypoint.sh" ]
