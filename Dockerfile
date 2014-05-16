# forked from https://gist.github.com/jpetazzo/5494158

FROM	ubuntu:14.04
MAINTAINER	Joan Marc Carbo Arnau "jmcarbo@gmail.com"

# prevent apt from starting postgres right after the installation
#RUN	echo "#!/bin/sh\nexit 101" > /usr/sbin/policy-rc.d; chmod +x /usr/sbin/policy-rc.d

RUN apt-get update
RUN	LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y -q postgresql postgresql-contrib openssh-server curl

#RUN	LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y -q postgresql-9.3 postgresql-contrib-9.3
#RUN rm -rf /var/lib/apt/lists/*
RUN apt-get clean


RUN echo "listen_addresses = '*'" >> /etc/postgresql/9.3/main/postgresql.conf
RUN echo "host all all all md5"  >> /etc/postgresql/9.3/main/pg_hba.conf
RUN /usr/bin/pg_ctlcluster 9.3 main start && ( echo "ALTER USER postgres PASSWORD 'abc123'" | sudo -u postgres psql )

RUN mkdir -p /var/run/sshd
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config
#RUN sed -ri 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config

RUN curl https://github.com/hecticjeff/shoreman/raw/master/shoreman.sh -sLo /usr/bin/shoreman && chmod 755 /usr/bin/shoreman
RUN echo "sshd: /usr/sbin/sshd -D" >>/Procfile
RUN echo "pg_ctlcluster 9.3 main start" >>/Procfile
RUN locale-gen en_US.UTF-8 
RUN useradd -s /bin/bash -m -p $(echo "abc123" | openssl passwd -1 -stdin) deploy
RUN usermod -a -G sudo deploy

EXPOSE 5432
EXPOSE 2224
EXPOSE 22

CMD    /usr/bin/shoreman /Procfile
