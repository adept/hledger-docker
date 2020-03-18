FROM haskell:8.6.5 as dev

ENV RESOLVER lts-14.27

RUN stack setup --resolver=$RESOLVER
RUN echo "allow-newer: true" >> /root/.stack/config.yaml
RUN stack install --resolver=$RESOLVER \
    hledger-lib-1.17 \
    hledger-1.17 \
    hledger-ui-1.17 \
    hledger-web-1.17 \
    hledger-iadd-1.3.10 \
    hledger-interest-1.5.4

FROM debian:stable-slim

MAINTAINER Dmitry Astapov <dastapov@gmail.com>

RUN apt-get update && apt-get install --yes libgmp10 libtinfo5 sudo && rm -rf /var/lib/apt/lists
RUN adduser --system --ingroup root hledger
RUN usermod -aG sudo hledger
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

COPY --from=dev /root/.local/bin/hledger* /usr/bin/

ENV LC_ALL C.UTF-8

COPY data /data
VOLUME /data

EXPOSE 5000 5001

COPY start.sh /start.sh

USER hledger
WORKDIR /data

CMD ["/start.sh"]
