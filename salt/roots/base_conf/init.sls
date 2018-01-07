/root/.bashrc:
  file.managed:
    - source: salt://base_conf/bash/bashrc.template
    - user: root
    - group: root
    - mode: 0700
steam:
  user.present:
    - fullname: steam
    - shell: /bin/bash
    - home: /home/steam
    - password: $1$lUjJBBBC$8Vo2h4tLs363LGFx56Fxo0
    - groups:
      - users
      - sudo
  file.managed:
    - name: /home/steam/.bashrc
    - source: salt://base_conf/bash/bashrc.template
    - user: steam
    - group: steam
    - mode: 0700
repo-required-pkgs:
  pkg.installed:
    - names:
      - memcached
      - ufw
      - perl-modules
      - lsof
      - libc6-i386
      - lib32gcc1
      - bzip2
rbenv-deps:
  pkg.installed:
    - names:
      - bash
      - git
      - gcc
      - openssl
      - libssl-dev
      - make
      - curl
      - autoconf
      - bison
      - build-essential
      - libffi-dev
      - libyaml-dev
      - libreadline6-dev
      - zlib1g-dev
      - libncurses5-dev
ruby-2.3.1:
  rbenv.installed:
    - default: True
    - user: steam
    - require:
      - pkg: rbenv-deps