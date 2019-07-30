FROM haskell as dev

RUN stack setup --resolver=lts-12
RUN stack install --resolver=lts-12 \
    cassava-megaparsec-2.0.0 \
    config-ini-0.2.3.0 \
    easytest-0.2.1 \
    megaparsec-7.0.2 \
    hledger-lib-1.12 \
    hledger-1.12 \
    hledger-ui-1.12 \
    hledger-web-1.12 \
    hledger-api-1.12 \
    hledger-diff-0.2.0.14 \
    hledger-iadd-1.3.7

FROM debian:stable-slim

MAINTAINER Dmitry Astapov <dastapov@gmail.com>

RUN apt-get update && apt-get install --yes libgmp10 libtinfo5 && rm -rf /var/lib/apt/lists
RUN adduser --system --ingroup root hledger

COPY --from=dev /root/.local/bin/hledger* /usr/bin/

ENV LC_ALL C.UTF-8

COPY data /data
VOLUME /data

EXPOSE 5000 5001

COPY start.sh /start.sh

USER hledger
WORKDIR /data

CMD ["/start.sh"]
