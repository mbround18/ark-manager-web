#!/usr/bin/env bash

# Base upgrade
apt-get update
apt-get install -y software-properties-common

add-apt-repository multiverse
dpkg --add-architecture i386
apt-get update
apt install lib32gcc1 steamcmd

apt-get install -y \
memcached \
git \
autoconf \
bison \
build-essential \
libssl-dev \
libyaml-dev \
libreadline6-dev \
zlib1g-dev \
libncurses5-dev \
libffi-dev \
libgdbm3 \
libgdbm-dev \
wget \
perl-modules \
curl \
lsof \
libc6-i386 \
lib32gcc1 \
bzip2 \
steamcmd

useradd -m steam
cd /home/steam || return

curl -sL http://git.io/vtf5N | bash -s steam


