#!/bin/bash
## INPUTS: branchName - Ex: "5.13", "5.14", "master"

set -ex

## Determine which version of bknix to load
function pick_bknix() {
  case "$branchName" in
    4.6|5.7|5.13)
      use-bknix old
      ;;
    *)
      use-bknix min
      ;;
  esac
}


if [ -e $HOME/.profile ]; then . $HOME/.profile; fi
eval $(pick_bknix)
if [ -z "$BKITBLD" ]; then echo "Invalid BKPROF"; exit 1; fi

echo "== Platform versions =="
php --version
mysql --version
echo
echo

export FILE_SUFFIX=$( date -u '+%Y%m%d%H%M' )
## Note: Not safe for concurrent build
BLDNAME="cividist"
BLDDIR="$BKITBLD/$BLDNAME"
OUTDIR="$WORKSPACE/output"

## Validate inputs
if [[ $branchName =~ ^[a-zA-Z0-9\.\-]+$ ]] ; then
  echo "Branch name looks OK"
else
  echo "Malformed branch name"
  exit 1
fi

if [ "$branchName" = "4.6" ]; then
  echo 'CREATE DATABASE IF NOT EXISTS nothing;GRANT SELECT ON `nothing`.* TO "nobody"@"localhost" IDENTIFIED BY "thesearentthedroidsyourelookingfor";GRANT SELECT ON `nothing`.* TO "nobody"@"127.0.0.1" IDENTIFIED BY "thesearentthedroidsyourelookingfor";' | amp sql -a

  if ! php -r 'error_reporting(E_ALL); $v = mysql_real_escape_string("sql ok"); echo $v;' | grep -q 'sql ok' ; then
    echo "Cannot build CiviCRM 4.6 on this host. Configure PHP-MySQL default privileges."
    exit 1
  fi
fi

## Ensure the build exists and has clean data dir
if [ ! -d "$BLDDIR" ]; then
  civibuild create "$BLDNAME" --type dist --web-root "$BLDDIR"
elif [ -d "$BLDDIR/web" ]; then
  rm -rf "$BLDDIR/web"
fi
mkdir -p "$BLDDIR/web"

## Build the tarballs
pushd "$BLDDIR"
  cividist update
  cividist build "origin/${branchName}"

  ## Don't need these files on gcloud
  find web -name README.html -delete
  find web -name .htaccess -delete
popd

## Put the tarballs in the workspace
[ -d "$OUTDIR" ] && rm -rf "$OUTDIR"
mkdir "$OUTDIR"
cp -rL "$BLDDIR"/web/by-date/latest/* "$OUTDIR"

## Clear out some space
rm -rf "$BLDDIR/web"
mkdir "$BLDDIR/web"
