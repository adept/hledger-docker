# build.sh reads the version from here
ARG HLEDGER_VERSION=1.52.4
ARG GHC_VERSION=9.12.4
# Snapshot for the add-ons from Hackage. Independent of HLEDGER_VERSION, so that
# hledger version bumps don't rebuild them.
ARG RESOLVER=nightly-2026-08-27

# hledger, hledger-ui, hledger-web and the scripts from hledger's bin/
FROM haskell:${GHC_VERSION} AS dev
ARG HLEDGER_VERSION

ENV LC_ALL=C.UTF-8

WORKDIR /build
RUN git clone --depth 1 --branch ${HLEDGER_VERSION} https://github.com/simonmichael/hledger && cd hledger && stack install hledger hledger-ui hledger-web
RUN cd /build/hledger/bin && ./compile.sh

# The add-ons listed in README.md. compile.sh doesn't strip them;
# hledger-bar is a shell script.
RUN cd /build/hledger/bin && \
    for s in balance-as-budget balance-as-budget-multi check-fancyassertions check-postable check-tagfiles \
             combine-balances move register-max register-max2 smooth swap-dates; do \
        strip -o /root/.local/bin/hledger-$s hledger-$s; \
    done && \
    cp hledger-bar /root/.local/bin/

# Add-ons from Hackage and git. Only /root/.stack/pantry (Hackage index and
# package sources) is cached: mounting all of /root/.stack would hide the
# base image's config.yaml (system-ghc: true).
FROM haskell:${GHC_VERSION} AS extras
ARG RESOLVER

ENV LC_ALL=C.UTF-8

# Needs fixes for 1.42
RUN --mount=type=cache,target=/root/.stack/pantry,sharing=locked \
    stack install --resolver=$RESOLVER hledger-stockquotes-0.1.3.2

# Needs fixes for multi-interval bug
# RUN stack install --resolver=$RESOLVER hledger-interest-1.6.7

# Needs fixes for 1.41
RUN --mount=type=cache,target=/root/.stack/pantry,sharing=locked \
    stack install --resolver=$RESOLVER hledger-iadd-1.3.22

# Simplify this once hledger-interest merges in multi-interval fix
WORKDIR /build
RUN --mount=type=cache,target=/root/.stack/pantry,sharing=locked \
    git clone --depth 1 https://github.com/adept/hledger-interest && cd hledger-interest && stack install --resolver=$RESOLVER hledger-interest && cd .. && rm -rf hledger-interest

# Python tools, in a venv built against the same python3 as the runtime image
FROM debian:bookworm-slim AS pyvenv

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates git python3 python3-venv && apt-get clean && rm -rf /var/lib/apt/lists

RUN python3 -m venv /usr/app/venv && /usr/app/venv/bin/pip install --no-cache-dir \
    pricehist==1.4.16 \
    git+https://gitlab.com/nobodyinperson/hledger-utils@d950b889cec3d1b73eb9cdaa30501561779f4866 \
    git+https://github.com/edkedk99/hledger-lots@a1fdd32bf996bca9cadeca7a94391bfc75aa755a

# Not needed at runtime. Keep __pycache__: the venv isn't writable by the
# hledger user, so without it every run would recompile pandas, matplotlib etc.
RUN /usr/app/venv/bin/pip uninstall -y setuptools pip && \
    find /usr/app/venv -type d -name tests -prune -exec rm -rf {} +

FROM debian:bookworm-slim

LABEL org.opencontainers.image.authors="Dmitry Astapov <dastapov@gmail.com>"

RUN apt-get update && apt-get install --yes --no-install-recommends libgmp10 libtinfo6 sudo less python3 && apt-get clean && rm -rf /var/lib/apt/lists
RUN adduser --system --ingroup root hledger && usermod -aG sudo hledger && mkdir /.cache && chmod 0777 /.cache
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

COPY --from=dev /root/.local/bin/hledger* /usr/bin/
COPY --from=extras /root/.local/bin/hledger-stockquotes /root/.local/bin/hledger-iadd /root/.local/bin/hledger-interest /usr/bin/
COPY --from=pyvenv /usr/app/venv /usr/app/venv

ENV PATH="/usr/app/venv/bin:$PATH" \
    LC_ALL=C.UTF-8 \
    MPLCONFIGDIR=/tmp/matplotlib

COPY data /data
VOLUME /data

EXPOSE 5000 5001

COPY start.sh entrypoint.sh /

USER hledger
WORKDIR /data

ENTRYPOINT ["/entrypoint.sh"]
