#!/bin/bash
set -ex

if [ -e $HOME/.profile ]; then . $HOME/.profile; fi
eval $(use-bknix "dfl")
if [ -z "$BKITBLD" ]; then echo "Invalid BKPROF"; exit 1; fi

TRASHDIR=/tmp/buildkit-trash
EXITCODE=0
export AMP_INSTANCES_TIMEOUT=360
civi-download-tools

##########################################################################################
## Helpers

## Prepare a name for a trash folder
## usage: path=$(mk_trash_name)
function mk_trash_name() {
  if [ ! -d "$TRASHDIR" ]; then
    mkdir "$TRASHDIR"
    chmod o= "$TRASHDIR"
  fi
  local file=$(mktemp.php trash- "$TRASHDIR")
  rm -f "$file"
  echo "$file"
}


## Attempt to delete a folder. If it fails, display a warning and carry on
## usage: rm_softly <dir> <trash-dir>
function rm_softly() {
  if [ -n "$1" -a ! -e "$1" ]; then
    return
  fi
  if [ -z "$1" -o ! -d "$1" ]; then
    echo "rm_softly requires a path"
    exit 1
  fi
  if rm -rf "$1" ; then
    echo "Directory removed ($1)"
  else
    echo "Directory partially removed ($1)"
  fi
}

##########################################################################################
## Main
BLDDIR=$BKITBLD/$BLDNAME
BLDBAK=$(mk_trash_name)

case "$series" in
  STABLE|RC|NIGHTLY|46NIGHTLY) echo "Building with $series tarball" ;;
  *) echo "The requested build series is not recognized"; exit 1 ;;
esac

case "$BLDNAME" in
  backdrop) TARBALL="civicrm-${series}-backdrop.tar.gz" ;;
  joomla) TARBALL="civicrm-${series}-joomla.zip" ;;
  drupal) TARBALL="civicrm-${series}-drupal.tar.gz" ;;
  wordpress) TARBALL="civicrm-${series}-wordpress.zip" ;;
  wporg) TARBALL="civicrm-${series}-wporg.zip" ;;
  *) echo "Cannot determine TARBALL for BLDNAME=$BLDNAME"; exit 1 ;;
esac

TARURL="https://download.civicrm.org/latest/$TARBALL"
# TARPATH="$HOME/download/$TARBALL"

  if [ -d "$BLDDIR" ]; then
    mv "$BLDDIR" "$BLDBAK"
    rm_softly "$BLDBAK"
  fi
  [ -f "$BLDDIR.sh" ] && rm -f "$BLDDIR.sh"
  
#  [ ! -d "$HOME/download" ] && mkdir "$HOME/download" 
#  curl -Iv "$TARURL" -o "$TARPATH"
  
  if civihydra create "$TARURL"  ; then
    set +x
    echo "======================="
    echo "[[ Create succeeded. ]]"
    echo "======================="
    set -x
  else
    set +x
    echo ""
    echo "======================="
    echo "[[ Create failed. ]]"
    echo "======================="
    set -x
    EXITCODE=1
  fi

exit $EXITCODE
