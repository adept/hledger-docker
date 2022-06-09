FROM haskell:8.10.4 as dev

ENV RESOLVER lts-18.5
ENV LC_ALL=C.UTF-8

RUN stack setup --resolver=$RESOLVER && stack install --resolver=$RESOLVER \
    hledger-lib-1.26 \
    hledger-1.26 \
    hledger-ui-1.26 \
    hledger-web-1.26 \
    hledger-interest-1.6.4 \
    hledger-stockquotes-0.1.2.1 

#    hledger-iadd-1.3.17 \

FROM debian:stable-slim

MAINTAINER Dmitry Astapov <dastapov@gmail.com>

RUN apt-get update && apt-get install --yes libgmp10 libtinfo6 sudo && rm -rf /var/lib/apt/lists
RUN adduser --system --ingroup root hledger && usermod -aG sudo hledger && mkdir /.cache && chmod 0777 /.cache
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
