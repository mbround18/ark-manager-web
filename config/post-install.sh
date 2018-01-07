#!/usr/bin/env bash
write_nginx_config() {

echo "Writing config file to /etc/nginx/conf.d/$1"

cat <<EOT > /etc/nginx/conf.d/$1
server {
  listen 8080;
  server_name _; # This is just an invalid value which will never trigger on a real hostname.

  location / {
        proxy_set_header        Host '\$host';
        proxy_set_header        X-Real-IP '\$remote_addr';
        proxy_set_header        X-Forwarded-For '\$proxy_add_x_forwarded_for';
        proxy_set_header        X-Forwarded-Proto '\$scheme';
        proxy_pass              http://127.0.0.1:6000;
  }


}
EOT

sed -i "s/'//g" /etc/nginx/conf.d/$1

}


echo "If your nginx does not include /etc/nginx/conf.d please modify your config to include that directory."

if [ ! -d "/etc/nginx/conf.d"  ]; then
 mkdir -p /etc/nginx/conf.d
fi

if [ -f "/etc/nginx/conf.d/ark-server-manager.conf"  ]; then
 echo "Writting new config as an existing one was found. please review the changes and adapt as necessary. They are at /etc/nginx/conf.d/"
 write_nginx_config "ark-server-manager.conf.new"
else
 write_nginx_config "ark-server-manager.conf"
 echo "Restarting Nginx with ark-server-manager.conf available"
 service nginx restart
fi