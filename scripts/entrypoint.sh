#!/bin/bash

# Gibs me access <3
sudo /root.sh

# turn on bash's job control
set -m

# ARK/gsm-instance defaults — override any of these via docker run -e
export APP_ID="${APP_ID:-376030}"
export INSTALL_PATH="${INSTALL_PATH:-${ARK_DIRECTORY:-/home/steam/ARK}}"
export EXECUTABLE="${EXECUTABLE:-./ShooterGame/Binaries/Linux/ShooterGameServer}"
export NAME="${NAME:-ARK Server}"
export LAUNCH_MODE="${LAUNCH_MODE:-native}"

# Compatibility bridge: old ADDITIONAL_*_ARGS → new env vars
if [[ -z "${LAUNCH_ARGS}" && -n "${ADDITIONAL_START_ARGS}" ]]; then
  export LAUNCH_ARGS="${ADDITIONAL_START_ARGS}"
fi
if [[ -z "${INSTALL_ARGS}" && -n "${ADDITIONAL_INSTALL_ARGS}" ]]; then
  export INSTALL_ARGS="${ADDITIONAL_INSTALL_ARGS}"
fi

# Start the HTTP/API server in the background
SERVER_ADDRESS="0.0.0.0" \
PUBLIC_PATH="/home/steam/ark-manager-web/dist" \
  /home/steam/ark-manager-web/server &

# Start the agent (Unix socket command daemon) — foreground
/home/steam/ark-manager-web/agent

# Bring server back to foreground
fg %1
