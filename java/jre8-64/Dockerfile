FROM avinb/ubuntu:latest
MAINTAINER avinash barnwal <avin.barnwal@gmail.com>
# This is 64 bit version of JRE build
ENV javatz jre-8u66-linux-x64.tar.gz
ENV javadest jre1.8.0_66
RUN apt-get install -y unzip \
	&& mkdir -p /usr/local/java \
	&& cd /usr/local/java \ 
	&& curl -L -O -H "Cookie: oraclelicense=accept-securebackup-cookie" -k  http://download.oracle.com/otn-pub/java/jdk/8u66-b17/$javatz \
	&& curl -L -O -H "Cookie: oraclelicense=accept-securebackup-cookie" -k  http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip \
	&& unzip jce_policy-8.zip \
#Clean Dependencies
	&& apt-get remove unzip curl ca-certificates -y \
	&& apt-get -y autoremove \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
#Install the Java and Configure Path Variables .
	&& cd /usr/local/java \
	&& tar xzf ${javatz} \
	&& echo 'export JAVA_HOME=/usr/local/java/${javadest}'>> /etc/profile \
	&& echo 'export JRE_HOME=$JAVA_HOME' >> /etc/profile \
	&& echo 'export PATH=$PATH:$JAVA_HOME/bin' >> /etc/profile \
# Update Alternatives
	&& update-alternatives --install "/usr/bin/java" "java" "/usr/local/java/${javadest}/bin/java" 1 \
# patch with jce patch
	&& cp UnlimitedJCEPolicyJDK8/*.jar /usr/local/java/${javadest}/lib/security/ \
	&& chown -R root:root "/usr/local/java/${javadest}" \
# cleanup
	&& rm -rf UnlimitedJCEPolicyJDK8 \
	&& rm -rf /usr/local/java/${javatz} \
	&& rm -rf jce_policy-8.zip \
WORKDIR /opt2
