# Spotify Cassandra 2.1 Base Image
#
# VERSION               0.2
#
# Installs Cassandra 2.1 package. Does only basic configuration.
# Tokens and seed nodes should be configured by child images.

FROM ubuntu:14.04

# install java
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -q
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:webupd8team/java
RUN apt-get update -q
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java7-installer curl

RUN mkdir -p /opt/cassandra

# exclude javadocs, takes up most space
RUN curl http://mirror.catn.com/pub/apache/cassandra/2.1.2/apache-cassandra-2.1.2-bin.tar.gz \
  | tar zxf - --strip-components 1 --exclude '*/javadoc*' -C /opt/cassandra

VOLUME /opt/cassandra/data

ENV CASSANDRA_CONFIG /opt/cassandra/conf

# Necessary since cassandra is trying to override the system limitations
# See https://groups.google.com/forum/#!msg/docker-dev/8TM_jLGpRKU/dewIQhcs7oAJ
RUN rm -f /etc/security/limits.d/cassandra.conf

EXPOSE 7199 7000 7001 9160 9042 22 8012 61621
WORKDIR /opt/cassandra

ADD run.sh /opt/cassandra/run.sh
CMD ["./run.sh"]
