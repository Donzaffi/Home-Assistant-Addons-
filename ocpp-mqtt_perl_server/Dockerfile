ARG BUILD_FROM
FROM ${BUILD_FROM}

RUN apk add --no-cache \
    perl \
    bash

WORKDIR /opt/ocpp

COPY upstream/ /opt/ocpp/
COPY run.sh /run.sh

RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
