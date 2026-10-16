#!/bin/bash
# Check that every tool listed in README.md starts in the given image.
# USAGE: ./smoke_test.sh IMAGE
set -e -o pipefail

image="${1:?USAGE: $0 IMAGE}"

tools=( hledger hledger-web hledger-ui hledger-iadd hledger-interest
    hledger-stockquotes pricehist hledger-edit hledger-plot
    hledger-lots hledger-balance-as-budget hledger-bar
    hledger-balance-as-budget-multi hledger-check-fancyassertions
    hledger-check-postable hledger-check-tagfiles
    hledger-combine-balances hledger-move hledger-register-max2
    hledger-register-max hledger-smooth hledger-swap-dates )

# Run as an arbitrary uid, like README and run.sh recommend
docker container run --rm -i --user "$(id --user)" \
       --env LEDGER_FILE=/data/hledger.journal \
       --entrypoint bash "$image" -s "${tools[@]}" <<'EOF'
failed=0
echo assets > /tmp/commands.txt
for t in "$@"; do
    case "$t" in
        # ignores --help, insists on exactly three arguments
        hledger-balance-as-budget-multi) args=("$LEDGER_FILE" "$LEDGER_FILE" /tmp/commands.txt) ;;
        *) args=(--help) ;;
    esac
    if out=$(timeout 30 "$t" "${args[@]}" 2>&1 </dev/null); then
        echo "ok    $t"
    else
        echo "FAIL  $t: $(tail -n 3 <<<"$out")"
        failed=1
    fi
done
hledger print >/dev/null || { echo "FAIL  hledger print"; failed=1; }
exit $failed
EOF

# Containers below are named, so that they get removed even if a check
# fails or times out (killing the docker CLI doesn't stop the container)
name="hledger-smoke-$$"
cleanup() { docker container rm -f "$name" >/dev/null 2>&1 || true; }
trap cleanup EXIT

# The entrypoint runs commands as given and passes options to hledger-web
out=$(timeout 30 docker container run --rm --name "$name" "$image" hledger --version 2>&1) || true
cleanup
if grep -q '^hledger ' <<<"$out"; then
    echo "ok    entrypoint: command"
else
    echo "FAIL  entrypoint: command: $(tail -n 3 <<<"$out")"; exit 1
fi
out=$(timeout 30 docker container run --rm --name "$name" "$image" --version 2>&1) || true
cleanup
if grep -q '^hledger-web ' <<<"$out"; then
    echo "ok    entrypoint: hledger-web options"
else
    echo "FAIL  entrypoint: hledger-web options: $(tail -n 3 <<<"$out")"; exit 1
fi

# hledger-web actually serves pages, as the image's user and as an arbitrary uid
check_web() {
    local label="$1" status="" i
    shift
    docker container run -d --name "$name" "$@" "$image" >/dev/null
    for i in $(seq 30); do
        [ "$(docker container inspect -f '{{.State.Running}}' "$name" 2>/dev/null)" = true ] || break
        status=$(docker container exec "$name" bash -c \
            'exec 3<>/dev/tcp/127.0.0.1/5000 && printf "GET / HTTP/1.0\r\n\r\n" >&3 && head -n 1 <&3' 2>/dev/null) && break
        sleep 1
    done
    if [[ "$status" =~ ^HTTP/1\.[01]\ [23] ]]; then
        echo "ok    hledger-web serves pages ($label)"
        cleanup
    else
        echo "FAIL  hledger-web serves pages ($label): ${status:-no response}"
        docker container logs "$name" 2>&1 | tail -n 3 | cut -c 1-300
        exit 1
    fi
}
check_web "default user"
check_web "--user" --user "$(id --user)"
