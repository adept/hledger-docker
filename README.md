# Docker image for hledger and associated tools

This docker image provides [hledger](http://hledger.org/), the plain text accounting software, and
associated tools:

 * hledger-web, web interface for hledger
 * hledger-ui, curses interface for hledger
 * hledger-iadd, interactive console frontend for "hledger add"
 * hledger-api, which server hledger data and reports as a JSON web API
 * hledger-diff, tool to diff journal files

## Usage

### Hledger-web + hledger-api

By default, container will start hledger-web on port 5000 and hledger-api on port 5001, both of them reading journal `hledger.journal` from volume `data`:

```
docker run -d -v "$HOME/hledger-data:/data" -p 5000:5000 dastapov/hledger
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

You can just drop into a shell in container and run hledger there:
```
docker run --rm -v "$HOME/hledger-data:/data" dastapov/hledger bash
```

Or you can replace `bash` with a suitable invocation of `hledger`:

```
docker run --rm -v "$HOME/hledger-data:/data" dastapov/hledger hledger -f /data/hledger.journal stats
```

Make sure you provide `--rm` agrument to `docker run`, otherwise your containers will be kept in container
registry even after you are done with them, which is probably not what you want.

### Using image for hledger development

You can use the supplied Dockerfile to get yourself an image for hledger development. Build target `dev`
will get you Debian-based image with `stack` and all the build dependencies of `hledger` installed:

```
docker image build --tag hledger-dev --target dev .
```
