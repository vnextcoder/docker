FROM avinb/jre8-32:latest
MAINTAINER Avinash Barnwal <vnextcoder@gmail.com> 
RUN echo 'we are running some # of cool things'
ENV TEAMCITY_DATA_PATH=/var/lib/teamcity \
    TEAMCITY_HOME=/opt/lib/teamcity \
    TEAMCITY_VERSION=9.1.3 \
    TEAMCITY_LOGS=/opt/lib/teamcity/logs \
    DEBIAN_FRONTEND=noninteractive
# create user and group first
RUN 	groupadd -g 999 teamcity \
	&& useradd -u 999 -g teamcity -d ${TEAMCITY_DATA_PATH} teamcity \
	&& sed -i -e 's/exit 101/exit 0/g' /usr/sbin/policy-rc.d \
	&& apt-get update -y \
	&& apt-get install -y --no-install-recommends \
            curl \
            ca-certificates  \
#install teamcity now
	&& mkdir -p ${TEAMCITY_HOME} \
	&& mkdir -p ${TEAMCITY_DATA_PATH} \
	&& curl -L -o /Teamcity-${TEAMCITY_VERSION}.tar.gz http://download.jetbrains.com/teamcity/TeamCity-${TEAMCITY_VERSION}.tar.gz \
	&& curl -sSL -o /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
	&& chmod +x /usr/local/bin/gosu \
#cleanup of apt-get
	&& apt-get remove -y curl \
	&& apt-get -y autoremove \
	&& apt-get -y clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 
RUN 	tar zxf /Teamcity-${TEAMCITY_VERSION}.tar.gz -C /opt/lib \  
	&& rm -rf /Teamcity-${TEAMCITY_VERSION}.tar.gz \
	&& mv /opt/lib/TeamCity/* ${TEAMCITY_HOME} \
# Cleanup of teamcity default agent
	&& rm -fr ${TEAMCITY_HOME}/buildAgent \
	&& rm -fr /opt/lib/TeamCity 


# install gosu for easy step-down from root
	#&& curl -sL -o /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
    	#&& gpg --verify /usr/local/bin/gosu.asc \
    	#&& rm /usr/local/bin/gosu.asc \

ADD starteam130.jar /opt/lib/teamcity/webapps/ROOT/WEB-INF/lib/
ADD starteam130-resources.jar /opt/lib/teamcity/webapps/ROOT/WEB-INF/lib/
VOLUME ${TEAMCITY_DATA_PATH}
VOLUME ${TEAMCITY_LOGS}

WORKDIR ${TEAMCITY_HOME}
EXPOSE 8111

COPY ./teamcity-entry.sh /
RUN chmod +x /teamcity-entry.sh
ENTRYPOINT ["/teamcity-entry.sh"]

CMD ["/opt/lib/teamcity/bin/teamcity-server.sh", "run"]
