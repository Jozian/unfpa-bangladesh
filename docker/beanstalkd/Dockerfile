FROM ubuntu:bionic

ARG PORT
ARG LISTEN
ARG BINLOG_PATH

# Set up environment
ENV LANG=C.UTF-8
ENV PORT=${PORT:-11300}
ENV LISTEN=${LISTEN:-0.0.0.0}
ENV BINLOG_PATH=${BINLOG_PATH:-/var/lib/beanstalkd}

RUN apt-get -yq update \
        && DEBIAN_FRONTEND=noninteractive apt-get install -y \
                unattended-upgrades \
                beanstalkd \
        && rm -rf /var/lib/apt/lists/*

EXPOSE ${PORT}
VOLUME ["${BINLOG_PATH}"]
COPY entrypoint /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
