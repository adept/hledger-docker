FROM haskell:9.10.1-bullseye as dev

ENV RESOLVER=nightly-2025-05-01 \
    LC_ALL=C.UTF-8 \
    PATH="/usr/app/venv/bin:$PATH"

RUN ghc --version
RUN stack setup --resolver=$RESOLVER 
RUN apt-get update && apt-get install -y --no-install-recommends git python3-pip python3-venv && apt-get clean && rm -rf /var/lib/apt/lists
#RUN stack install --resolver=$RESOLVER base-compat-0.14.0
#RUN stack install --resolver=$RESOLVER microlens-platform-0.4.3.5 hashable-1.4.7.0 hledger-lib-1.43 hledger-1.43 hledger-ui-1.43 hledger-web-1.43
WORKDIR /build
RUN git clone --depth 1 --branch 1.43 https://github.com/simonmichael/hledger && cd hledger && ls && stack install --verbose hledger hledger-ui hledger-web
RUN cd /build/hledger/bin && ./compile.sh && cp hledger* /root/.local/bin/

# Needs fixes for 1.42
RUN stack install --resolver=$RESOLVER hledger-stockquotes-0.1.3.2

# Needs fixes for multi-interval bug
# RUN stack install --resolver=$RESOLVER hledger-interest-1.6.7

# Needs fixes for 1.41
RUN stack install --resolver=$RESOLVER hledger-iadd-1.3.21

WORKDIR /usr/app

RUN python3 -m venv /usr/app/venv && pip3 install --no-cache-dir \
    git+https://gitlab.com/chrisberkhout/pricehist \
    git+https://gitlab.com/nobodyinperson/hledger-utils \
    git+https://github.com/edkedk99/hledger-lots

# Simplify this once hledger-interest merges in multi-interval fix
WORKDIR /build
RUN git clone https://github.com/adept/hledger-interest && cd hledger-interest && stack install --resolver=$RESOLVER hledger-interest && cd .. && rm -rf hledger-interest

RUN cd /root/.local/bin/ && rm *.o *.hi *.hs && ls /root/.local/bin/

FROM debian:bookworm-slim

MAINTAINER Dmitry Astapov <dastapov@gmail.com>

RUN apt-get update && apt-get install --yes --no-install-recommends libgmp10 libtinfo6 sudo less && apt-get clean && rm -rf /var/lib/apt/lists
RUN adduser --system --ingroup root hledger && usermod -aG sudo hledger && mkdir /.cache && chmod 0777 /.cache
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

COPY --from=dev /root/.local/bin/hledger* /usr/bin/
COPY --from=dev /usr/app/venv /usr/app/venv

ENV PATH="/usr/app/venv/bin:$PATH" \
    LC_ALL=C.UTF-8

COPY data /data
VOLUME /data

EXPOSE 5000 5001

COPY start.sh /start.sh

USER hledger
WORKDIR /data

CMD ["/start.sh"]
