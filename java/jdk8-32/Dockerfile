FROM avinb/ubuntu:latest
MAINTAINER avinash barnwal
# This is 32 bit version of JDK build
ENV javatz jdk-8u66-linux-i586.tar.gz
ENV javadest jdk1.8.0_66
# libc6-386 is required on 64bit systems to run 32bit java.
# see the Ubuntu article for reference http://askubuntu.com/a/207750
RUN apt-get install -y unzip libc6-i386 \
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
	&& echo 'export JRE_HOME=$JAVA_HOME/jre' >> /etc/profile \
	&& echo 'export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin' >> /etc/profile \
# Update Alternatives
	&& update-alternatives --install "/usr/bin/java" "java" "/usr/local/java/${javadest}/jre/bin/java" 1 \
	&& update-alternatives --install "/usr/bin/javac" "javac" "/usr/local/java/${javadest}/bin/javac" 1 \
	&& update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/local/java/${javadest}/bin/javaws" 1 \
# patch with jce patch
	&& cp UnlimitedJCEPolicyJDK8/*.jar /usr/local/java/${javadest}/jre/lib/security/ \
	&& chown -R root:root "/usr/local/java/${javadest}" \
# cleanup
	&& rm -rf UnlimitedJCEPolicyJDK8 \
	&& rm -rf /usr/local/java/${javatz} \
	&& rm -rf jce_policy-8.zip \
WORKDIR /opt2
