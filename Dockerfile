FROM ubuntu:19.04

ADD setup.sh /root/setup.sh
RUN chmod +x /root/setup.sh && sed -i 's/\r//g' /root/setup.sh
RUN /root/setup.sh
RUN mkdir -p /home/steam/ark-manager-web
WORKDIR /home/steam/ark-manager-web
COPY . /home/steam/ark-manager-web