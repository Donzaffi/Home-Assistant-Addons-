ARG BUILD_FROM
FROM ${BUILD_FROM}

RUN \
    apk add --no-cache \
        perl \
        perl-dev \
        bash

WORKDIR /opt/ocpp

COPY upstream/ /opt/ocpp/

COPY run.sh /

RUN chmod +x /run.sh

CMD ["/run.sh"]
