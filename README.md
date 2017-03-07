# ark_manager_web

## Disclaimer

This software is provided to you without any authentication or access based security
it is up to you the user to install or develop your own security methods and best practices.

There may be future effort for security on this code base but only if its in popular demand.

## Supported Distributions
More operating systems can be supported in the future by popular demand.

 1. Ubuntu 16.04
 
 
## Packaged Installer
 On a fresh ubuntu 16.04 server run the following commands:
 ```bash
wget -qO - https://deb.packager.io/key | sudo apt-key add -
echo "deb https://deb.packager.io/gh/mbround18/ark_manager_web xenial master" | sudo tee /etc/apt/sources.list.d/ark_manager_web.list
sudo apt-get update
sudo apt-get install ark-manager-web
sudo ark-manager-web run bundle exec rake install:server_tools
sudo ark-manager-web run bundle exec rake install:ark_server
```

Temporarily `ark-manager-web scale` command is not working so please run the following to get the interface
to run.
```bash
ark-manager-web run interface
```

After running those commands you will have a web interface available on port `8080` however it is available to the world and you should 
scroll down till you see Recommendations for some ideas on how to secure this software.

## Self Installation:
This is an installation guide for an ubuntu based host and support for more OSes will 
be tested in the future.
### Required Software
The packages below must be installed with a sudo user:
```bash
# Required
memcached
curl
git
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
rbenv install 2.3.1 # Recommended Version as this is the version the source is based on 
rbenv shell 2.3.1 # Change the version number here if you are not using the recommended version

# Now we install bundle for ruby
gem install bundle

# Finally lets clone the repo
git clone $URL_HERE ~/ark_manager_web

# Setting up the repo
cd ~/ark_manager_web
bundle install --binstubs

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
If you wish to change this edit the `/path/to/ark_manager_web/config/unicorn.rb` file and change the listening field.
## Recommendations
It is recommended to set this up behind a `nginx` reverse proxy as well as enabling `ufw` to block
access to port 8080. That will prevent unwanted insecure access to the web interface. The next
suggestion would be to set up an htpasswd file with users or a seperate authentication system.

Another recommendation would be to set up supervisord to run the software for you so it will start on boot.

### Example Nginx Configuration
nginx.conf file, It is recommended to install `letsencrypt`/`cerbot` and generate a ssl for your site.
```
worker_processes  1;

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