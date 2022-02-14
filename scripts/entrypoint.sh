#!/bin/bash

# Gibs me access <3
sudo /root.sh

# turn on bash's job control
set -m

# Start the primary process and put it in the background
ROCKET_ADDRESS="0.0.0.0" \
PUBLIC_PATH="/home/steam/ark-manager-web/dist" \
  /home/steam/ark-manager-web/server &

# Start the helper process
/home/steam/ark-manager-web/agent

# the my_helper_process might need to know how to wait on the
# primary process to start before it does its work and returns

# now we bring the primary process back into the foreground
# and leave it there
fg %1
