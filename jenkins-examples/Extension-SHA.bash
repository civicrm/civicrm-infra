#!/bin/bash

########################################
BKITNAM="ext-$EXECUTOR_NUMBER"
BKITTYPE="drupal-clean"
#DRYRUN="-N"
DRYRUN=
#export OFFLINE=1
export PHPUNIT_BIN=phpunit4
BKPROF=dfl

########################################
## Local adaptation to get my env going
if [ -e $HOME/.profile ]; then . $HOME/.profile; fi
case "$BKPROF" in min|max|dfl) eval $(use-bknix "$BKPROF") ;; esac
if [ -z "$BKITBLD" ]; then echo "Invalid BKPROF"; exit 1; fi

########################################
## Run a command, but hide any sensitive environmet variables
function safedo() {
  local backupToken="$STATUS_TOKEN"
  local backupUrl="$STATUS_URL"
  STATUS_TOKEN=
  STATUS_URL=
  "$@"
  local retVal=$?
  STATUS_TOKEN="$backupToken"
  STATUS_URL="$backupUrl"
  return $retVal
}

function report_status() {
  h1 "Report status: $@"
  if [ -n "$STATUS_TOKEN" ]; then
    civici probot:status \
      --probot-url="$STATUS_URL" \
      --probot-token="$STATUS_TOKEN" \
      "$@"
  fi
}

function fakesleep() {
  if [ -n "$DRYRUN" ]; then
    h1 "Simulate a delay"
    sleep "$@"
  fi
}

function h1() {
  echo
  echo "================================================================================"
  echo "== $@"
}

########################################
[ -d "$WORKSPACE/junit" ] && "$WORKSPACE/junit"

########################################
report_status --state="pending" --desc="Build test environment ($CIVI_VER, $BKITTYPE)" --url="${BUILD_URL}console"

h1 "Build test site"
if ! safedo civici ext:build -v -f $DRYRUN \
  --git-url="$GIT_URL" \
  --base="$GIT_BASE" \
  --head="$GIT_HEAD" \
  --build="$BKITNAM" \
  --build-root="$BKITBLD" \
  --type="$BKITTYPE"
then
  report_status --state="failure" --desc="Failed to build test site"
  exit 1
fi

fakesleep 10

report_status --state="pending" --desc="Execute tests" --url="${BUILD_URL}console"

h1 "Execute tests"
safedo civici ext:test -vv $DRYRUN \
  --info="$BKITBLD/$BKITNAM/sites/default/files/civicrm/ext/target/info.xml" \
  --junit-dir="$WORKSPACE/junit"
EXITCODE=$?

h1 "Cleanup JUnit XML"
phpunit-xml-cleanup "$WORKSPACE"/junit/*.xml

report_status --junit-dir="$WORKSPACE"/junit \
  --state="@JUNIT_STATE@" --desc="@JUNIT_SUMMARY@" --url="$BUILD_URL"

exit $EXITCODE