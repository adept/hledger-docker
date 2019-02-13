# Docker image for hledger 1.13 and associated tools

This docker image provides [hledger](http://hledger.org/), the plain text accounting software, and
associated tools:

 * hledger-web, the web interface for hledger
 * hledger-ui, the curses interface for hledger
 * hledger-iadd, the interactive console frontend for "hledger add"
 * hledger-api, which serves hledger data and reports as a JSON web API
 * hledger-diff, the tool to diff journal files

## Usage

### Hledger-web + hledger-api

By default, container will start hledger-web on port 5000 and hledger-api on port 5001, both of them reading journal `hledger.journal` from volume `data`, so assuming your journal is in `~/journals/all.journal`, you can run:

```
docker run --rm -d -e HLEDGER_JOURNAL_FILE=/data/all.journal -v "$HOME/journals:/data" -p 5000:5000 -p 5001:5001 --user $(id --user) dastapov/hledger
```

and navigate to `http://localhost:5000` for hledger-web and URLs like `http://localhost:5001/api/v1/accounts` for hledger-api.

If you have LEDGER_FILE environmed variable defined already, you can try:
```
docker run --rm -d -e HLEDGER_JOURNAL_FILE=/data/$(basename $LEDGER_FILE) -v "$(dirname $LEDGER_FILE):/data" -p 5000:5000 -p 5001:5001 --user $(id --user) dastapov/hledger
```

#### Environment variables

 * `HLEDGER_JOURNAL_FILE`
   * input file (default: /data/hledger.journal)
 * `HLEDGER_HOST`
   * set the TCP host (default: 0.0.0.0)
 * `HLEDGER_PORT`
   * set the TCP port (default: 5000)
 * `HLEDGER_API_PORT`
   * set the TCP port (default: 5001)
 * `HLEDGER_DEBUG`
   * debug output (default: 1, increase for more)
 * `HLEDGER_BASE_URL`
   * set the base url (default: http://localhost:$HLEDGER_PORT)
 * `HLEDGER_FILE_URL`
   * set the static files url (default: $HLEDGER_BASE_URL/static)
 * `HLEDGER_RULES_FILE`
   * CSV conversion rules file (default: /data/hledger.rules)

### hledger cli

You can use this image to run command-line version of hledger (or hledger-iadd, hledger-ui, ...) by
providing alternative start command to `docker run`.

You can just drop into a shell in the container and run hledger there (remember to include `-it`):
```
docker run --rm -it -v "$HOME/hledger-data:/data" --user $(id --user) dastapov/hledger bash
```

Alternatively, you can replace `bash` with a suitable invocation of `hledger`:

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
