#!/bin/bash
set -ex

#### Config
PROGRAM=git-scan.phar
TMPFILE=bin/git-scan.phar
REVISION=$(date +'%Y-%m-%d')-$(git rev-parse HEAD | head -c8)
PHP=/usr/bin/php

export PATH="$HOME/buildkit/bin:$HOME/bin:$PATH"

#### Build it
[ -d vendor ] && rm -rf vendor
[ -f "$TMPFILE" ] && rm -f "$TMPFILE"
$PHP `which composer` install --no-scripts
$PHP -dphar.readonly=0 `which box` build

#### Publish
[ -d tmp ] && rm -rf tmp
mkdir tmp
cp "$TMPFILE" "tmp/${PROGRAM}"
cp "$TMPFILE" "tmp/${PROGRAM}-${REVISION}"
