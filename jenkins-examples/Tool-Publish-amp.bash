#!/bin/bash
set -ex

#### Setup environment
if [ -e "$HOME/.profile" ]; then . "$HOME/.profile"; fi
eval $(use-bknix min)
if [ -z "$BKITBLD" ]; then echo "Invalid BKPROF"; exit 1; fi
bknix update

#### Config
PROGRAM=amp.phar
TMPFILE=amp.phar
REVISION=$(date +'%Y-%m-%d')-$(git rev-parse HEAD | head -c8)

#### Build it
[ -d vendor ] && rm -rf vendor
[ -f "$TMPFILE" ] && rm -f "$TMPFILE"
composer install --no-scripts
php -dphar.readonly=0 `which box` build

#### Publish
[ -d tmp ] && rm -rf tmp
mkdir tmp
cp "$TMPFILE" "tmp/${PROGRAM}"
cp "$TMPFILE" "tmp/${PROGRAM}-${REVISION}"
