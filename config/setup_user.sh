#!/usr/bin/env bash
if [ -d "/home/steam" ]; then
    if [ -d "/opt/arkmanagerweb" ]; then
        if [ ! -f  "/home/steam" ]; then
            touch /home/steam/.bashrc
        fi
        chown -R steam:steam /home/ark
        su - steam -c "cd /opt/arkmanagerweb; bundle install"
   fi
fi