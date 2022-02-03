# Client Build
FROM --platform=linux/amd64 mbround18/ark-manager-client:latest as ClientBuild

# ----------------------- #
# -- Project Mangement -- #
# ----------------------- #

FROM docker.io/mbround18/cargo-make:latest as cargo-make

# ------------- #
# -- Planner -- #
# ------------- #
FROM docker.io/lukemathwalker/cargo-chef:latest-rust-1.58-alpine as planner
WORKDIR /data/project
COPY ./Cargo.lock ./Cargo.toml ./
COPY ./server ./server
COPY ./agent ./agent
RUN cargo chef prepare --recipe-path recipe.json

# ------------- #
# -- Builder -- #
# ------------- #
FROM docker.io/lukemathwalker/cargo-chef:latest-rust-1.58-alpine as builder
WORKDIR /data/project
COPY --from=planner /data/project/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json
COPY ./Cargo.lock ./Cargo.toml ./
COPY ./server ./server
COPY ./agent ./agent
COPY --from=cargo-make /usr/local/bin/cargo-make /usr/local/cargo/bin
RUN /usr/local/cargo/bin/cargo make release

# ------------- #
# -- Runtime -- #
# ------------- #
FROM registry.hub.docker.com/library/debian:11-slim as RustRuntime
WORKDIR /apps
COPY --from=builder /data/project/target/release/server ./
COPY --from=builder /data/project/target/release/agent ./

# Bundled Together
FROM docker.io/steamcmd/steamcmd:ubuntu

ENV TZ=America/Los_Angeles

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone \
    && apt-get update                             \
    && apt-get upgrade -y                         \
    && apt-get install -y -q                      \
    # Image utilities
    htop net-tools nano gcc g++ gdb               \
    netcat curl wget zip unzip                    \
    sudo dos2unix bash                            \
    # Ark Server Tools requirements
    perl-modules lsof libc6-i386 lib32gcc1 bzip2  \
    # Steam Specific
    libsdl2-2.0-0  jq   libc6-dev                 \
    # Clean Up apt lists
    && rm -rf /var/lib/apt/lists/*



RUN addgroup --system steam     \
    && adduser --system         \
      --home /home/steam        \
      --shell /bin/bash         \
      steam                     \
    && usermod -aG steam steam  \
    && chmod ugo+rw /tmp/dumps  \
    && usermod -u 2000 steam    \
    && groupmod -g 2000 steam

RUN curl -sL https://git.io/arkmanager | bash -s steam \
    && mkdir -p /home/steam/ark-manager-web
COPY --from=RustRuntime /apps/server /home/steam/ark-manager-web/
COPY --from=RustRuntime /apps/agent /home/steam/ark-manager-web/
COPY --from=ClientBuild /apps/client /home/steam/ark-manager-web/dist
COPY ./scripts/entrypoint.sh /entrypoint.sh


RUN chown -R steam:steam /home/steam \
    && usermod -d /home/steam steam

USER steam
ENV HOME=/home/steam
WORKDIR /home/steam

HEALTHCHECK --interval=1m --timeout=3s \
            CMD curl -f http://127.0.0.1:8000/heartbeat || exit 1

ENTRYPOINT [ "/entrypoint.sh" ]
