# Ark Manager Web

---


## Disclaimer

> This project has gone through a major rewrite and the project you knew it as is no more! Why?
It was riddled with out of date & no longer supported technology. Angular 1 is dead & ruby just couldnt keep up with concurrent requests.

1) This project is designed for single instances in mind. 

2) This software is provided to you without any authentication or access based security
it is up to you the user to install or develop your own security methods and best practices.

3) There may be future effort for security on this code base but only if its in popular demand.

##### Migrating from Angular 1 version

I have NOT tested it as this project is from 2016-2017 but this should be able to be a drop in replacement.

## Usage

```shell
docker run \
  -p "8000:8000" \
  -p "7777:7777/tcp" \
  -p "7777:7777/udp" \
  -p "27015:27015/tcp" \
  -p "27015:27015/udp" \
  -v "./ARK:/home/steam/ARK" \ 
  mbround18/ark-manager-web:latest
```

## Recommendations

 - If you are hosting this on a server, it is recommended to set this up behind a `nginx` reverse proxy with http basic auth & ssl for port 8000;
 - You do not need to volume mount the `/tmp/ark-manager-web` directory. It can be destroyed at any point. 
