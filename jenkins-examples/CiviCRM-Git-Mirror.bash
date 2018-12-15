#!/bin/bash
set -e

#############################
#### Helpers

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
    git clone --mirror "$srcUrl" "$localFolder"
  fi

  pushd "$localFolder" >> /dev/null
    echo "Update mirror ($srcUrl => $destUrl via $localFolder)"

    git remote set-url origin "$srcUrl"
    git remote set-url --push origin "$destUrl"

    git fetch -p origin
    git push --mirror
  popd >> /dev/null
}

#############################
#### Main

##          LOCAL FOLDER             SOURCE REPO URL                                  DESTINATION REPO URL
mirror_repo ~/src/civicrm-core       "git@github.com:civicrm/civicrm-core.git"        "git@lab.civicrm.org:dev/core.git"
mirror_repo ~/src/civicrm-wordpress  "git@github.com:civicrm/civicrm-wordpress.git"   "git@lab.civicrm.org:dev/wordpress.git"
mirror_repo ~/src/l10n               "git@lab.civicrm.org:dev/translation.git"        "git@github.com:civicrm/l10n.git"
#mirror_repo ~/src/l10n               "git@github.com:civicrm/l10n.git"	               "git@lab.civicrm.org:dev/translation.git"
