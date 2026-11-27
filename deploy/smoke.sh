#!/usr/bin/env bash
# The image as deployed: compose.yaml without a database, then the pages that
# answer without one. ci runs it with the image loaded as ghcr.io/zyx-tw/plump:ci.
set -euo pipefail
trap 'docker compose logs; docker compose down -v' EXIT
sed -e 's/^PLUMP_VERSION=.*/PLUMP_VERSION=ci/' -e 's/^PLUMP_BIND=.*/PLUMP_BIND=127.0.0.1:3999/' .env.example > .env
docker compose up -d --wait web
base=http://127.0.0.1:3999
for path in / /icon.svg /favicon.ico /apple-icon.png; do
  code=$(curl -s -o /dev/null -w '%{http_code}' "$base$path")
  echo "$path $code"
  test "$code" = 200
done
curl -sI "http://127.0.0.1:3999/env/potsdamer_platz/metadata.json" | grep -qi "^access-control-allow-origin: \*"
echo smoke ok
