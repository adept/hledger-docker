FROM haskell:latest as dev

ENV RESOLVER lts-14.3

RUN stack setup --resolver=$RESOLVER
RUN stack install --resolver=$RESOLVER \
    hledger-lib-1.15.1 \
    hledger-1.15.1 \
    hledger-ui-1.15 \
    hledger-web-1.15 \
    hledger-iadd-1.3.9 \
    hledger-interest-1.5.3

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
