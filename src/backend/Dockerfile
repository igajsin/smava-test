FROM alpine:3.8

MAINTAINER Igor Gaisin <igor@gajsin.name>

COPY helloworld.war /helloworld.war

ENV JAVA_HOME=/opt/jre \
    PATH=${PATH}:/opt/jre/bin

# download Oracle Java8
RUN apk update \
    && apk add wget \
    && mkdir /opt; cd /opt \
    && wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jre-8u181-linux-x64.tar.gz" \
    && tar -xzf jre-8u181-linux-x64.tar.gz

# install glibc
# TODO: do not rely on external/unofficial resources
RUN apk --no-cache add ca-certificates wget \
    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-2.28-r0.apk \
    && apk add glibc-2.28-r0.apk

RUN ln -s /opt/jre1.8.0_181/ /opt/jre \
    && apk add paxctl \
    && paxctl -c /opt/jre/bin/java \
    && paxctl -m /opt/jre/bin/java

CMD java -jar /helloworld.war

EXPOSE 8080
