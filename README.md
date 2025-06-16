# Docker image for hledger and associated tools

This docker image provides [hledger](http://hledger.org/), the plain text accounting software, and
associated tools:

 * hledger-web, the web interface for hledger
 * hledger-ui, the curses interface for hledger
 * [hledger-iadd](https://hackage.haskell.org/package/hledger-iadd), the interactive console frontend for "hledger add"
 * [hledger-interest](https://hackage.haskell.org/package/hledger-interest), tool to compute interest for loan/mortgage accounts
 * [hledger-stockquotes](https://hackage.haskell.org/package/hledger-stockquotes), tool to fetch stock prices from AlphaVantage (though they recently restricted their API to 25 requests per day, sadly)
 * [pricehist](https://gitlab.com/chrisberkhout/pricehist), tool to fetch currency and stock prices from a variety of sources
 * [hledger-utils](https://gitlab.com/nobodyinperson/hledger-utils), package that provides `hledger edit` and `hledger plot`
 * [hledger-lots](https://github.com/edkedk99/hledger-lots), tool to manage investment lots

And various add-ons from the hledger repository `bin` dir:

 * hledger-balance-as-budget
 * hledger-check-fancyassertions
 * hledger-check-postable
 * hledger-check-tagfiles
 * hledger-combine-balances
 * hledger-move
 * hledger-print-location
 * hledger-register-max2
 * hledger-register-max
 * hledger-smooth
 * hledger-swap-dates

## Image versions/tags

 * Most recent: `latest`,`1.43.2`,`latest-dev`,`1.43.2-dev`
 * Legacy: `1.43.1`,`1.43.1-dev`,`1.43`,`1.43-dev`,`1.42.1`,`1.42.1-dev`,`1.42`,`1.42-dev`,`1.41`,`1.41-dev`,`1.40`,`1.40-dev`,`1.34`,`1.34-dev`,`1.33.1`,`1.33.1-dev`,`1.33`,`1.33-dev`,`1.32.3`,`1.32.3-dev`,`1.32.2`,`1.32.2-dev`,`1.32.1`,`1.32.1-dev`,`1.31`,`1.31-dev`,`1.30.1`,`1.30.1-dev`,`1.29.2`,`1.29.2-dev`,`1.29.1`,`1.29.1-dev`,`1.28`,`1.28-dev`,`1.27.1`,`1.27.1-dev`,`1.27`,`1.27-dev`,`1.26`,`1.26-dev`,`1.25`,`1.25-dev`,`1.24.1`,`1.24.1-dev`,`1.24`,`1.24-dev`,`1.23`,`1.23-dev`,`1.22.2`,`1.22.2-dev`,`1.22.1`,`1.22.1-dev`,`1.22`,`1.22-dev`,`1.21`,`1.21-dev`,`1.20.4`,`1.20.4-dev`,`1.20.3`,`1.20.3-dev`,`1.20.2`,`1.20.2-dev`,`1.20`,`1.20-dev`,`1.19.1`,`1.19.1-dev`,`1.19`,`1.19-dev`,`1.18.1`,`1.18.1-dev`,`1.18`,`1.18-dev`,`1.17.1.1`,`1.17`,`1.16.2`,`1.16.1`,`1.15.2`,`1.15.1`,`1.14`,`1.14.1`,`1.14.2`

## Usage

### Hledger-web

By default, container will start hledger-web on port 5000, reading journal `hledger.journal` from volume `data`, so assuming your journal is in `~/journals/all.journal`, you can run:

```
docker run --rm -d -e HLEDGER_JOURNAL_FILE=/data/all.journal -v "$HOME/journals:/data" -p 5000:5000 --user $(id --user) dastapov/hledger
```

and navigate to `http://localhost:5000` for hledger-web

If you have LEDGER_FILE environmed variable defined already, you can try:
```
docker run --rm -d -e HLEDGER_JOURNAL_FILE=/data/$(basename $LEDGER_FILE) -v "$(dirname $LEDGER_FILE):/data" -p 5000:5000 --user $(id --user) dastapov/hledger
```

Any extra arguments you provide will be passed to `hledger-web`.

Github repo contains helper script that simplifies invocation:
```
./run.sh ~/journals/all.journal web
```

#### Environment variables

 * `HLEDGER_JOURNAL_FILE`
   * input file (default: /data/hledger.journal)
 * `HLEDGER_HOST`
   * set the TCP host (default: 0.0.0.0)
 * `HLEDGER_PORT`
   * set the TCP port (default: 5000)
 * `HLEDGER_DEBUG`
   * debug output (default: 1, increase for more)
 * `HLEDGER_BASE_URL`
   * set the base url (default: http://localhost:$HLEDGER_PORT)
 * `HLEDGER_RULES_FILE`
   * CSV conversion rules file (default: /data/hledger.rules)
 * `HLEDGER_ARGS`
   * extra arguments you want to pass to hledger-web. You can supply extra arguments on the command line as well, but environment variable is useful for docker-compose recipes.

### hledger cli in the shell

You can use this image to run command-line version of hledger (or hledger-iadd, hledger-ui, ...) by
providing alternative start command to `docker run`.

You can just drop into a shell in the container and run hledger there (remember to include `-it`):
```
docker run --rm -it -v "$HOME/hledger-data:/data" --user $(id --user) dastapov/hledger bash
```

Github repo contains helper script that simplifies invocation:
```
./run.sh ~/journals/all.journal bash
```

### hledger cli via docker run

You can use `docker run` to invoke `hledger` directly:

```
docker run --rm -v "$HOME/hledger-data:/data" --user $(id --user) dastapov/hledger hledger -f /data/hledger.journal stats
```

Make sure you provide `--rm` argument to `docker run`, otherwise your containers will be kept in the container
registry even after you are done with them, which is probably not what you want.

### Using image for hledger development

You can use the supplied Dockerfile to get yourself an image for hledger development. Build target `dev`
will get you Debian-based image with `stack` and all the build dependencies of `hledger` installed:

```
docker image build --tag hledger-dev --target dev .
```

Alternatively, you can use pre-built image via `latest-dev` or `VERSION-dev` tags:
```
docker run --rm -it -v "$HOME/hledger-data:/data" dastapov/hledger:latest-dev bash
```
