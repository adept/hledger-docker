FROM haskell:9.6.4 as dev

ENV RESOLVER lts-22.17
ENV LC_ALL=C.UTF-8

RUN stack setup --resolver=$RESOLVER 
RUN stack install --resolver=$RESOLVER process-1.6.19.0 Cabal-3.10.1.0 haskeline-0.8.2.1 vty-0.2.0.1 hledger-lib-1.40 hledger-1.40 hledger-ui-1.40 hledger-web-1.40
RUN stack install --resolver=$RESOLVER hledger-stockquotes-0.1.2.2
RUN stack install --resolver=$RESOLVER hledger-interest-1.6.6
RUN stack install --resolver=$RESOLVER process-1.6.19.0 Cabal-3.10.1.0 haskeline-0.8.2.1 vty-0.2.0.1 hledger-lib-1.34 hledger-iadd-1.3.21
# RUN apt-get update && apt-get install -y python3-pip && pip3 install --prefix=/install git+https://gitlab.com/nobodyinperson/hledger-utils git+https://github.com/edkedk99/hledger-lots && rm -rf /var/lib/apt/lists

FROM debian:bullseye-slim

MAINTAINER Dmitry Astapov <dastapov@gmail.com>

RUN apt-get update && apt-get install --yes libgmp10 libtinfo6 sudo && rm -rf /var/lib/apt/lists
RUN adduser --system --ingroup root hledger && usermod -aG sudo hledger && mkdir /.cache && chmod 0777 /.cache
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

COPY --from=dev /root/.local/bin/hledger* /usr/bin/
# COPY --from=dev /install /usr/

ENV LC_ALL C.UTF-8

COPY data /data
VOLUME /data

EXPOSE 5000 5001

COPY start.sh /start.sh

USER hledger
WORKDIR /data

CMD ["/start.sh"]
