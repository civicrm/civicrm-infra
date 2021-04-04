#!/bin/bash
set -ex

if [ -e $HOME/.profile ]; then . $HOME/.profile; fi
case "$BKPROF" in min|max|dfl) eval $(use-bknix "$BKPROF") ;; esac
if [ -z "$BKITBLD" ]; then echo "Invalid BKPROF"; exit 1; fi
# Set ENV for the TMPDIR so that mosaico test and mosaico build don't clobber each other
npm config set tmp "/home/$USER/npm-tmp/"

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
BLDDIR="$BKITBLD/$BLDNAME/web"
EXTBASE="$BLDDIR/sites/all/modules/civicrm/ext"
EXITCODE=0

##################################################
## Resolve metadata for this extension
case "$EXTKEY" in
  nz.co.fuzion.extendedreport)
    EXTGITS="https://github.com/eileenmcnaughton/nz.co.fuzion.extendedreport"
    EXTS="nz.co.fuzion.extendedreport"
    ;;
  com.iatspayments.civicrm)
    EXTGITS="https://github.com/iATSPayments/com.iatspayments.civicrm"
    EXTS="com.iatspayments.civicrm"
    ;;
  org.civicrm.flexmailer)
    EXTGITS="https://github.com/civicrm/org.civicrm.flexmailer"
    EXTS="org.civicrm.flexmailer"
    ;;
  org.civicrm.api4)
    EXTGITS="https://github.com/civicrm/org.civicrm.shoreditch https://github.com/civicrm/api4"
    EXTS="org.civicrm.shoreditch org.civicrm.api4"
    ;;
  uk.co.vedaconsulting.mosaico)
    EXTGITS="https://github.com/civicrm/org.civicrm.flexmailer https://github.com/civicrm/org.civicrm.shoreditch https://github.com/veda-consulting/uk.co.vedaconsulting.mosaico"
    EXTS="org.civicrm.flexmailer org.civicrm.shoreditch uk.co.vedaconsulting.mosaico"
    ;;
  org.civicoop.civirules)
    #EXTGITS="https://github.com/civicoop/org.civicoop.civirules"
    EXTGITS="https://lab.civicrm.org/extensions/civirules"
    EXTS="org.civicoop.civirules"
    ;;
  *)
    echo "Unrecognized extension key: $EXTKEY"
    exit 1
    ;;
esac

## APIv4 has been merged into core since 5.19
if [ $EXTKEY == "org.civicrm.api4" ]; then
  case "$CIVIVER" in
    5.18|5.13)
     ;;
    *)
	 echo "APIv4 Extension tests are disabled from 5.19 onwards"
     exit 0
     ;;
  esac
fi

##################################################
## Reset (cleanup after previous tests)
[ -d "$WORKSPACE/junit" ] && rm -rf "$WORKSPACE/junit"
[ -d "$WORKSPACE/civibuild-html" ] && rm -rf "$WORKSPACE/civibuild-html"
if [ -d "$BLDDIR" ]; then
  echo y | civibuild destroy "$BLDNAME"
fi
mkdir "$WORKSPACE/junit"
mkdir "$WORKSPACE/civibuild-html"

## Report details about the test environment
civibuild env-info

## Download application (with civibuild)
civibuild download "$BLDNAME" \
  --civi-ver "$CIVIVER" \
  --type "drupal-clean"
mkdir -p "$EXTBASE"
pushd "$BLDDIR/sites/all/modules/civicrm"
EXTCIVIVER=$( php -r '$x=simplexml_load_file("xml/version.xml"); echo $x->version_no;' )
popd
pushd "$EXTBASE"
  if [ $BUILDTYPE = "git" ]; then
    for EXTGIT in $EXTGITS ; do
      ## NOTE: api4 may already exist in some build-types, so tread gently with it
      if [ $EXTGIT = "https://github.com/civicrm/api4" ]; then 
        if [ -d "api4" ]; then 
          cd api4
          git checkout master && git pull && cd ../
        else
          git clone "$EXTGIT"
        fi
      else
        git clone "$EXTGIT"
      fi
      EXTGITDIR=$(basename "$EXTGIT")
      if [ -f "$EXTGITDIR/bin/setup.sh" ]; then
        pushd "$EXTGITDIR"
          ./bin/setup.sh -D
        popd
      fi
    done
  else
    for EXT in $EXTS ; do
      cv dl -b "@https://civicrm.org/extdir/ver=$EXTCIVIVER|cms=Drupal|status=|ready=/$EXT.xml" --to="$EXTBASE/$EXT" --dev
      EXTDIR=$(basename "$EXT")
      #if [ -f "$EXTDIR/bin/setup.sh" ]; then
        #pushd "$EXTDIR"
          #chmod +x ./bin/setup.sh
          #./bin/setup.sh -D
        #popd
      #fi
    done
  fi
popd

## Install application (with civibuild)
civibuild install "$BLDNAME" \
  --admin-pass "n0ts3cr3t"

## Report details about this build of the application
civibuild show "$BLDNAME" \
  --html "$WORKSPACE/civibuild-html" \
  --last-scan "$WORKSPACE/last-scan.json" \
  --new-scan "$WORKSPACE/new-scan.json"
cp "$WORKSPACE/new-scan.json" "$WORKSPACE/last-scan.json"

## Run the tests
pushd "$EXTBASE"
  if [ $BUILDTYPE = "git" ]; then
    EXTDIR=$(basename "$EXTGIT")
  else
    EXTDIR=$(basename "$EXT")
  fi
  pushd "$EXTDIR"
    civibuild restore "$BLDNAME"
    cv en "$EXTKEY"
#    if [ "$EXTKEY" = "org.civicrm.api4" ]; then cv flush; fi ## FIX+REMOVE ME
#    phpunit5 --tap --group e2e --log-junit="$WORKSPACE/junit/junit-e2e.xml"
#    phpunit5 --tap --group headless --log-junit="$WORKSPACE/junit/junit-headless.xml"
    phpunit6 --printer='Civi\Test\TAP' --group e2e --log-junit="$WORKSPACE/junit/junit-e2e.xml"
    phpunit6 --printer='Civi\Test\TAP' --group headless --log-junit="$WORKSPACE/junit/junit-headless.xml"
#    phpunit7 --printer='Civi\Test\TAP' --group e2e --log-junit="$WORKSPACE/junit/junit-e2e.xml"
#    phpunit7 --printer='Civi\Test\TAP' --group headless --log-junit="$WORKSPACE/junit/junit-headless.xml"
    EXITCODE=$(($? || $EXITCODE))
  popd
popd

phpunit-xml-cleanup "$WORKSPACE/junit/"/*.xml
npm config delete tmp

## Report test results
# Jenkins should be configured to read JUnit XML from $WORKSPACE/junit
exit $EXITCODE
