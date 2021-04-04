#!/bin/bash
set -ex

## Given an extension with "info.xml" and a version "1.2",
## publish a release with version "1.2.{timestamp}".
##
## The release includes three deliverables:
## 1. The ZIP file
## 2. The update info.xml file
## 3. A report of the git repos used

#### Setup environment
if [ -e "$HOME/.profile" ]; then . "$HOME/.profile"; fi
eval $(use-bknix "min")
if [ -z "$BKITBLD" ]; then echo "Invalid BKPROF"; exit 1; fi
#bknix update

#### Config
VERSION=$(civix info:get -x version).$(date '+%s')
DATE=$(date '+%Y-%m-%d')
OUTDIR="$PWD/build/out"
VOUTDIR="$OUTDIR/$VERSION"
LOUTDIR="$OUTDIR/latest"
EXT="uk.co.vedaconsulting.mosaico"
npm config set tmp "/home/$USER/npm-tmp/"

## Cleanup
[ -d "$PWD/build" ] && rm -rf "$PWD/build"
mkdir -p "$OUTDIR" "$VOUTDIR" "$LOUTDIR"
[ -d "packages/mosaico" ] && rm -rf "packages/mosaico"

## Build
bash bin/setup.sh -D
git scan export > "$VOUTDIR/${EXT}-${VERSION}-git.json"
civix info:set -x version -t "$VERSION"
civix info:set -x releaseDate -t "$DATE"
cp info.xml "$VOUTDIR/${EXT}-${VERSION}-info.xml"
bash bin/setup.sh -z
cp build/uk.co.vedaconsulting.mosaico.zip "$VOUTDIR/${EXT}-${VERSION}.zip"

git checkout -- info.xml

## Publish
for SUFFIX in "-git.json" "-info.xml" ".zip" ; do
  cp "$VOUTDIR/${EXT}-${VERSION}${SUFFIX}" "$LOUTDIR/${EXT}-latest${SUFFIX}"
done
