#!/bin/sh
# Build the watchapp and bundle it with the companion into an installable archive:
#   findphone.tar.gz  (findphone/{findphone.py, stoandl_ext.py, findphone.pbw})
#
# Then, on the machine running stoandl:  stoandl ext install findphone.tar.gz
set -e
here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

echo "Building the watchapp (needs the Pebble SDK — see README)…"
( cd "$here" && pebble build )

tmp=$(mktemp -d)
mkdir "$tmp/findphone"
cp "$here/findphone.py" "$here/stoandl_ext.py" "$here/build/findphone.pbw" "$tmp/findphone/"
tar czf "$here/findphone.tar.gz" -C "$tmp" findphone
rm -rf "$tmp"

echo "Created $here/findphone.tar.gz"
echo "Install it on the stoandl host:  stoandl ext install findphone.tar.gz"
