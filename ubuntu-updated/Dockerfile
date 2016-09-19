FROM ubuntu:latest
MAINTAINER avinash barnwal
# This is Base Dockerfile for building JDK/JRE images
RUN apt-get purge openjdk-\* \
	&& sed -i -e 's/exit 101/exit 0/g' /usr/sbin/policy-rc.d \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
            curl \
            ca-certificates \
        #&& rm -rf /var/lib/apt/lists/* \
	&& mkdir /opt2 \
	&& apt-get clean
	#&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
WORKDIR /opt2

