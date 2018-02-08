# vim:set ft=dockerfile:
FROM postgres:9.4
ENV TERM xterm-256color

RUN echo deb http://ftp.us.debian.org/debian jessie main >> /etc/apt/sources.list
RUN echo deb http://ftp.us.debian.org/debian jessie-backports main >> /etc/apt/sources.list
RUN echo deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main > /etc/apt/sources.list.d/webupd8team-java.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
RUN apt-get update
RUN apt-get clean
RUN apt-get update 
RUN apt-get --fix-missing -y --force-yes --no-install-recommends install git ca-certificates
RUN git clone https://github.com/tada/pljava.git
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get clean && apt-get update && apt-get --fix-missing -y --force-yes --no-install-recommends install g++ maven
RUN apt-get clean && apt-get update && apt-get --fix-missing -y --force-yes --no-install-recommends install postgresql-server-dev-9.4 libpq-dev
RUN apt-get clean && apt-get update && apt-get --fix-missing -y --force-yes --no-install-recommends install libecpg-dev libkrb5-dev
RUN apt-get clean && apt-get update && apt-get --fix-missing -y --force-yes --no-install-recommends install oracle-java8-installer libssl-dev
RUN export PGXS=/usr/lib/postgresql/9.4/lib/pgxs/src/makefiles/pgxs.mk
RUN cd pljava
RUN git checkout tags/V1_5_0
RUN mvn -Pwnosign clean install
RUN java -jar /pljava/pljava-packaging/target/pljava-pg9.4-amd64-Linux-gpp.jar
RUN cd ../
RUN apt-get -y remove --purge --auto-remove git ca-certificates g++ maven postgresql-server-dev-9.4 libpq-dev libecpg-dev libkrb5-dev oracle-java8-installer libssl-dev
RUN apt-get clean && apt-get update && apt-get --fix-missing -y --force-yes --no-install-recommends install openjdk-8-jdk-headless
RUN apt-get -y clean autoclean autoremove
RUN rm -rf ~/.m2 /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD /docker-entrypoint-initdb.d /docker-entrypoint-initdb.d

ENTRYPOINT ["/docker-entrypoint.sh"]
EXPOSE 5432
CMD ["postgres"]
