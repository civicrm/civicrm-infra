#!/bin/bash
set -ex

if [ -e $HOME/.profile ]; then . $HOME/.profile; fi
case "$BKPROF" in min|max|dfl) eval $(use-bknix "$BKPROF") ;; esac
if [ -z "$BKITBLD" ]; then echo "Invalid BKPROF"; exit 1; fi

## Job Name: CiviCRM-Ext-Matrix
## Job Description: Periodically run the unit tests for extensions
## Job GitHub Project URL: https://github.com/civicrm/civicrm-core
## Job Source Code Management: None
## Job Triggers: Scheduled
## Job xUnit Files: WORKSPACE/output/*.xml
## Useful vars: $CIVIVER (e.g. "4.5", "4.6", "master")
## Pre-requisite: Install civicrm-buildkit; configure amp
## Pre-requisite: Configure /etc/hosts and Apache with "build-1.l", "build-2.l", ..., "build-6.l"

BLDNAME="build-$EXECUTOR_NUMBER"
BLDURL="http://build-$EXECUTOR_NUMBER.l"
BLDDIR="$BKITBLD/$BLDNAME"
EXTBASE="$BLDDIR/sites/all/modules/civicrm/ext"
EXITCODE=0

##################################################
## Resolve metadata for this extension
case "$EXTKEY" in
  nz.co.fuzion.extendedreport)
    EXTGITS="https://github.com/eileenmcnaughton/nz.co.fuzion.extendedreport"
    ;;
  com.iatspayments.civicrm)
    EXTGITS="https://github.com/iATSPayments/com.iatspayments.civicrm"
    ;;
  org.civicrm.flexmailer)
    EXTGITS="https://github.com/civicrm/org.civicrm.flexmailer"
    ;;
  org.civicrm.api4)
    EXTGITS="https://github.com/civicrm/org.civicrm.shoreditch https://github.com/civicrm/api4"
    ;;
  uk.co.vedaconsulting.mosaico)
    EXTGITS="https://github.com/civicrm/org.civicrm.flexmailer https://github.com/civicrm/org.civicrm.shoreditch https://github.com/veda-consulting/uk.co.vedaconsulting.mosaico"
    ;;
  org.civicoop.civirules)
    #EXTGITS="https://github.com/civicoop/org.civicoop.civirules"
    EXTGITS="https://lab.civicrm.org/extensions/civirules"
    ;;
  *)
    echo "Unrecognized extension key: $EXTKEY"
    exit 1
    ;;
esac

##################################################
## Reset (cleanup after previous tests)
[ -d "$WORKSPACE/junit" ] && rm -rf "$WORKSPACE/junit"
[ -d "$WORKSPACE/civibuild-html" ] && rm -rf "$WORKSPACE/civibuild-html"
if [ -d "$BLDDIR" ]; then
  echo y | civibuild destroy "$BLDNAME"
fi
mkdir "$WORKSPACE/junit"
mkdir "$WORKSPACE/civibuild-html"

## Download application (with civibuild)
civibuild download "$BLDNAME" \
  --civi-ver "$CIVIVER" \
  --type "drupal-clean"
mkdir -p "$EXTBASE"
pushd "$EXTBASE"
  for EXTGIT in $EXTGITS ; do
    git clone "$EXTGIT"
    EXTGITDIR=$(basename "$EXTGIT")
    if [ -f "$EXTGITDIR/bin/setup.sh" ]; then
      pushd "$EXTGITDIR"
        ./bin/setup.sh -D
      popd
    fi
  done
popd

## Install application (with civibuild)
civibuild install "$BLDNAME" \
  --url "$BLDURL" \
  --admin-pass "n0ts3cr3t"

## Report details about this build of the application
civibuild show "$BLDNAME" \
  --html "$WORKSPACE/civibuild-html" \
  --last-scan "$WORKSPACE/last-scan.json" \
  --new-scan "$WORKSPACE/new-scan.json"
cp "$WORKSPACE/new-scan.json" "$WORKSPACE/last-scan.json"

## Run the tests
pushd "$EXTBASE"
  EXTGITDIR=$(basename "$EXTGIT")
  pushd "$EXTGITDIR"
    civibuild restore "$BLDNAME"
    cv en "$EXTKEY"
#    if [ "$EXTKEY" = "org.civicrm.api4" ]; then cv flush; fi ## FIX+REMOVE ME
    phpunit4 --tap --group e2e --log-junit="$WORKSPACE/junit/junit-e2e.xml"
    phpunit4 --tap --group headless --log-junit="$WORKSPACE/junit/junit-headless.xml"
    EXITCODE=$(($? || $EXITCODE))
  popd
popd

phpunit-xml-cleanup "$WORKSPACE/junit/"/*.xml


## Report test results
# Jenkins should be configured to read JUnit XML from $WORKSPACE/junit
exit $EXITCODE
