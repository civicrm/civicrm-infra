#!/bin/bash
set -ex

if [ -e $HOME/.profile ]; then . $HOME/.profile; fi
for BKPROF in dfl min max ; do
  (
    eval $(use-bknix "$BKPROF")
    if [ -z "$BKITBLD" ]; then echo "Invalid BKPROF"; exit 1; fi

    ## Expiration Period (ie all builds destroyed after...):           one week == 7*24 == 168 hours
    ## Redundancy Period (ie duplicate PR builds destroyed after...):  8 hours
    # [ML] 2018-01-19 lowered to 5 days, 4 hours
    find-stale-builds "$BKITBLD" 120 4 | while read BLD ; do
      echo y | civibuild destroy $(basename $BLD)
    done
  )
done
