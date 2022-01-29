# Ark Manager Web

---

## NOTICE

This project is in progress for a major rewrite. I am working toward making the upgrade be backwards compatible but it is a complete overhaul of the frontend, backend, and a new component that will be introduced called agent. The rewrites focus is on replicatability and scalability with the concept of simplicity being a key piece. 

Please see https://github.com/mbround18/ark-manager-web/issues/43 for rewrite updates. 


---


## Disclaimer

1) This project is designed for single instances in mind. If you are looking for a multi-instance/clustered ark server experience 
with a managed interface the new project called ark-overseer is under development.

2) This software is provided to you without any authentication or access based security
it is up to you the user to install or develop your own security methods and best practices.

3) There may be future effort for security on this code base but only if its in popular demand.

##### Migrating from version 1.x.x to 2.x.x or 2.x.x to 3.x.x

If you happen to be migrating from 1.x.x to 2.x.x you will need to perform the following:

1) Install Ruby version 2.3.6, `rbenv install 2.3.6`
2) Install bundler for new version, `gem install bundler`
3) Run `bundle install --binstubs`
4) Remove your current mod list file located in /project-dir/config/  labeled mod_list.json
5) Relaunch the web interface and let it run the updates for your mods to generate the new mod_list format. (This will take 30ish minutes)

## Supported Distributions
More operating systems can be supported in the future by popular demand.

 1. Ubuntu 16.04  
 
 
## Currently Unsupported:
 1. Multiple Instances
 2. Mod Installation, Reinstallation, and Removal
 3. Configuring game ini files

## Mod installation, reinstallation, removeal
If you wish to add a mod to your server please add it to the instance config in /home/steam/.config/arkmanager/instances/INSTANCENAME.cfg
On the line designated for ark mods following the format provided. Then follow what up by running the command: `arkmanager installmod MODID @INSTANCENAME`

The web interface has the ability to keep mods uptodate but unfortunately does not quite have the ability to install, reinstall, or remove mods just yet.

## Self Installation:
This is an installation guide for an ubuntu based host and support for more OSes will 
be tested in the future.

### Required Software
The packages below must be installed with a sudo user:
```bash
# Required for repo
memcached
git
# Required for rbenv and rbenv-build
curl
build-essential
autoconf 
bison 
lib32gcc1
libssl-dev 
libyaml-dev 
libreadline6-dev 
zlib1g-dev 
libncurses5-dev 
libffi-dev 
libgdbm3 
libgdbm-dev
# Requirements for ark-server-tools
perl-modules
lsof
libc6-i386
lib32gcc1
bzip2

```
The things below must be installed under a user account to prevent security
risks. It is suggested to install under the user name `steam` for consistency
sake.
```bash
# Install rbenv
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc

# Install rbenv-build
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build


# Install Ruby
cd ~
rbenv install 2.3.6 # Recommended Version as this is the version the source is based on 
rbenv shell 2.3.6 # Change the version number here if you are not using the recommended version

# Now we install bundle for ruby
gem install bundle

# Finally lets clone the repo
git clone https://github.com/mbround18/ark-manager-web.git ~/ark_manager_web

# Setting up the repo
cd ~/ark_manager_web
bundle --binstubs

# Set up the configuration
bundle exec rake configure

# Get Ark Manager
bundle exec rake install:server_tools

# Install Ark Server
bundle exec rake install:ark_server
```
### Running the interface:
Running the interface:
```bash
cd  ~/ark_manager_web
bundle exec unicorn -c ./config/unicorn.rb -D
```
This will allow the interface to be visible from `127.0.0.1:8080` of the machine its set up on.

If you wish to change this edit the `/path/to/ark_manager_web/config/env_config.json` file.
The only following allowed options are available:

| option  | description |
|---------|-------------|
| ARKMANAGER_PATH | /some/path/to/bin/where/arkmanager/is |
| ARK_INSTANCE_NAME | This is the name of the instance you will use. Default: main |
| MEMCACHE_ADDRESS | same for memcache |
| MEMCACHE_PORT | same for memcache |


```json
{
  "ARK_INSTANCE_NAME": "main",
  "ARKMANAGER_PATH": "/usr/local/bin",
  "MEMCACHE_ADDRESS": "127.0.0.1",
  "MEMCACHE_PORT": "11211"
}
```

## Recommendations
It is recommended to set this up behind a `nginx` reverse proxy as well as enabling `ufw` to block
access to port 8080. That will prevent unwanted insecure access to the web interface. The next
suggestion would be to set up an htpasswd file with users or a separate authentication system.

Another recommendation would be to set up supervisord to run the software for you so it will start on boot.

If you do choose to use `ufw` to secure port `8080` please also allow access for the following:
```bash
ufw allow 27016
ufw allow 7778
ufw allow 32330/tcp
```

### Example Nginx Configuration
nginx.conf file, It is recommended to install `letsencrypt`/`cerbot` and generate a ssl for your site.
```
worker_processes  4;

error_log  logs/error.log;

# pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;
    
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  logs/access.log  main;
    sendfile        on;
    keepalive_timeout  65;
    gzip  on;
    server_tokens off;


    server {
      listen 80;
      server_name YOUR_SERVER_NAME_HERE;
      listen 443 ssl;

      ssl_certificate /PATH/TO/CERT.pem;
      ssl_certificate_key /PATH/TO/PRIVATE_KEY.pem;
      ssl_dhparam /PATH/TO/DHPARAM_4096BIT.pem;      

      ssl_protocols TLSv1.2;
      ssl_prefer_server_ciphers on;
      ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
      ssl_ecdh_curve secp384r1; # Requires nginx >= 1.1.0
      ssl_session_cache shared:SSL:10m;
      ssl_session_tickets off; # Requires nginx >= 1.5.9
      ssl_stapling on; # Requires nginx >= 1.3.7
      ssl_stapling_verify on; # Requires nginx => 1.3.7

      add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";
      add_header X-Frame-Options DENY;
      add_header X-Content-Type-Options nosniff;
      add_header X-Robots-Tag none;
      add_header X-Download-Options noopen;
      add_header X-Permitted-Cross-Domain-Policies none;

      location / {
            auth_basic "Restricted Content";
            auth_basic_user_file /PATH/TO/.HTPASSWD_FILE;
	        proxy_set_header        Host $host;
	        proxy_set_header        X-Real-IP $remote_addr;
	        proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
	        proxy_set_header        X-Forwarded-Proto $scheme;
            proxy_pass              http://127.0.0.1:8080;
      }

      if ($scheme != "https") {
          return 301 https://$host$request_uri;
      }

    }     
}
```
