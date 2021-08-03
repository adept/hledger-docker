FROM haskell:8.8.4 as dev

ENV RESOLVER lts-16.31
ENV LC_ALL=C.UTF-8

RUN stack setup --resolver=$RESOLVER && stack install --resolver=$RESOLVER \
    hledger-lib-1.22.1 \
    hledger-1.22.1 \
    hledger-ui-1.22.1 \
    hledger-web-1.22.1 \
    pretty-simple-4.0.0.0 \
    prettyprinter-1.7.0 \
    hledger-iadd-1.3.15
#    hledger-interest-1.6.1 \

FROM debian:stable-slim

MAINTAINER Dmitry Astapov <dastapov@gmail.com>

RUN apt-get update && apt-get install --yes libgmp10 libtinfo6 sudo && rm -rf /var/lib/apt/lists
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
