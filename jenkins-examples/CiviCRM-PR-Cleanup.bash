#!/bin/bash
set -ex

if [ -e $HOME/.profile ]; then . $HOME/.profile; fi

if [ -d "/home/jenkins/buildkit" ]; then
  PRJDIR="/home/jenkins/buildkit"
elif [ -d "/srv/buildkit" ]; then
  PRJDIR="/srv/buildkit"
else
  echo "Failed to find PRJDIR"
  exit 1
fi

export PATH="$PRJDIR/bin:$PATH"

## Expiration: one week == 7*24 == 168
## Redundancy: 8 hours
# [ML] 2018-01-19 lowered to 5 days, 4 hours
find-stale-builds "$PRJDIR/build" 120 4 | while read BLD ; do
  echo y | civibuild destroy $(basename $BLD)
done
