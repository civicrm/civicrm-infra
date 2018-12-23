#!/bin/bash
set -ex

if [ -e $HOME/.profile ]; then . $HOME/.profile; fi
eval $(use-bknix min)
if [ -z "$BKITBLD" ]; then echo "Invalid BKPROF"; exit 1; fi
LOCHOME=$HOME/l10n/civicrm-l10n-core
cd $LOCHOME
git pull origin master
tx pull -a
$LOCHOME/bin/commit-to-git.sh
git push origin master
$LOCHOME/bin/compile-mo-files.sh
