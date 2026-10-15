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

# The entrypoint runs commands as given and passes options to hledger-web
if docker container run --rm "$image" hledger --version | grep -q '^hledger '; then
    echo "ok    entrypoint: command"
else
    echo "FAIL  entrypoint: command"; exit 1
fi
if timeout 30 docker container run --rm "$image" --version | grep -q '^hledger-web '; then
    echo "ok    entrypoint: hledger-web options"
else
    echo "FAIL  entrypoint: hledger-web options"; exit 1
fi
