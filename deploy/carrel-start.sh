#!/bin/sh
# carrel-deployd (from land) runs this from the release directory on every
# deploy and rollback: it moves /opt/plump to the release in VERSION, reports
# ready once the container is healthy, then follows its logs. The unit needs
# Type=notify and NotifyAccess=all.
set -eu

version=$(cat VERSION)
if [ -f compose.yaml ]; then
  cp compose.yaml /opt/plump/compose.yaml.new
  mv /opt/plump/compose.yaml.new /opt/plump/compose.yaml
fi
cd /opt/plump

tmp=$(mktemp .env.XXXXXX)
grep -v '^PLUMP_VERSION=' .env >"$tmp" || true
echo "PLUMP_VERSION=$version" >>"$tmp"
chmod 600 "$tmp"
mv "$tmp" .env

for try in 1 2 3; do
  docker compose pull --quiet web && break
  [ "$try" = 3 ] && exit 1
  sleep 2
done
docker compose up -d --wait web
systemd-notify --ready
exec docker compose logs -f --since 1s web
