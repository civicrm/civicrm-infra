#!/bin/bash
set -e

#############################
#### Helpers
# PRUNE=--prune
PRUNE=

## Synchronize content from one git repo to another
## usage: mirror_repo <local-folder> <src-url> <dest-url>
function mirror_repo() {
  local localFolder="$1"
  local srcUrl="$2"
  local destUrl="$3"

  echo ""
  echo "==================== $localFolder ===================="

  if [ ! -d "$localFolder" ]; then
    echo "Initialize local copy ($localFolder) of git repo ($srcUrl)"
    git clone --bare "$srcUrl" "$localFolder"
  fi

  pushd "$localFolder" >> /dev/null
    echo "Update mirror ($srcUrl => $destUrl via $localFolder)"

    git remote set-url origin "$srcUrl"
    git remote set-url --push origin "$destUrl"

    git fetch $PRUNE origin +refs/heads/*:refs/mirror/heads/*
    git fetch $PRUNE origin +refs/tags/*:refs/mirror/tags/*

    git push $PRUNE origin +refs/mirror/heads/*:refs/heads/*
    git push $PRUNE origin +refs/mirror/tags/*:refs/tags/*

  popd >> /dev/null
}

#############################
#### Main

#rm /tmp/fwop -rf; mkdir /tmp/fwop; pushd /tmp/fwop; git init --bare; popd

##          LOCAL FOLDER             SOURCE REPO URL                                  DESTINATION REPO URL
mirror_repo ~/src/civicrm-core       "git@github.com:civicrm/civicrm-core.git"        "git@lab.civicrm.org:dev/core.git"
mirror_repo ~/src/civicrm-wordpress  "git@github.com:civicrm/civicrm-wordpress.git"   "git@lab.civicrm.org:dev/wordpress.git"
##mirror_repo ~/src/civicrm-wordpress  "git@github.com:civicrm/civicrm-wordpress.git"   "file:///tmp/fwop"
mirror_repo ~/src/l10n               "git@lab.civicrm.org:dev/translation.git"        "git@github.com:civicrm/l10n.git"
##mirror_repo ~/src/l10n               "git@github.com:civicrm/l10n.git"	               "git@lab.civicrm.org:dev/translation.git"
