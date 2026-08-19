#!/bin/sh
set -eu

apk add --no-cache curl >/dev/null

URL="https://graphql.morrisons.site/"

# Apollo Router has no equivalent of the /version endpoint the Python/Node
# apps expose, so this can only confirm "a router is serving GraphQL
# traffic again" — not that this specific commit is the one live. Matches
# what k8s-graphql-router's own PostSync verify.sh already checks.
for i in $(seq 1 20); do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST \
    -H "Content-Type: application/json" \
    -d '{"query":"{__typename}"}' \
    "$URL")
  if [ "$STATUS" = "200" ]; then
    echo "PASS: $URL returned 200"
    exit 0
  fi
  echo "attempt $i: got status '$STATUS', retrying..."
  sleep 15
done

echo "FAIL: $URL never returned 200 after 20 attempts"
exit 1
