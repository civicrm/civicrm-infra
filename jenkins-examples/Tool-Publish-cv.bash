#!/bin/bash
set -ex

#### Config
PROGRAM=cv.phar
TMPFILE=bin/cv.phar
REVISION=$(date +'%Y-%m-%d')-$(git rev-parse HEAD | head -c8)
##FIXME PHP=/opt/php/5.4.45/bin/php
PHP=php

export PATH="$HOME/buildkit/bin:$HOME/bin:$PATH"

#### Build it
[ -d vendor ] && rm -rf vendor
[ -f "$TMPFILE" ] && rm -f "$TMPFILE"
$PHP `which composer` install --no-scripts --no-dev
$PHP -dphar.readonly=0 `which box` build

#### Publish
[ -d tmp ] && rm -rf tmp
mkdir tmp
cp "$TMPFILE" "tmp/${PROGRAM}"
cp "$TMPFILE" "tmp/${PROGRAM}-${REVISION}"
