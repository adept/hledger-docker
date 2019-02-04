FROM haskell as dev

RUN stack setup --resolver=lts-13
RUN stack install --resolver=lts-13 \
    brick-0.46 \
    text-zipper-0.10.1 \
    config-ini-0.2.4.0 \
    data-clist-0.1.2.2 \
    word-wrap-0.4.1 \
    hledger-lib-1.13.1 \
    hledger-1.13.2 \
    hledger-ui-1.13.1 \
    hledger-web-1.13 \
    hledger-api-1.13 \
    hledger-diff-0.2.0.14 \
    hledger-iadd-1.3.8

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
