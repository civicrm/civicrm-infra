#!/bin/bash
set -ex

if [ -e $HOME/.profile ]; then . $HOME/.profile; fi
case "$BKPROF" in min|max|dfl) eval $(use-bknix "$BKPROF") ;; esac
if [ -z "$BKITBLD" ]; then echo "Invalid BKPROF"; exit 1; fi

## Job Name: CiviCRM-E2E-Matrix
## Job Description: Periodically run the E2E unit tests on all major
##   major branches of civicrm-core.git
## Job GitHub Project URL: https://github.com/civicrm/civicrm-core
## Job Source Code Management: None
## Job Triggers: Scheduled
## Job xUnit Files: WORKSPACE/junit/*.xml
## Useful vars: $CIVIVER (e.g. "4.5", "4.6", "master")
## Pre-requisite: Install civicrm-buildkit; configure amp
## Pre-requisite: Configure /etc/hosts and Apache with "build-1.l", "build-2.l", ..., "build-6.l"

BLDNAME="build-$EXECUTOR_NUMBER"
EXITCODE=0

## Reset (cleanup after previous tests)
[ -d "$WORKSPACE/junit" ] && rm -rf "$WORKSPACE/junit"
[ -d "$WORKSPACE/civibuild-html" ] && rm -rf "$WORKSPACE/civibuild-html"
if [ -d "$BKITBLD/$BLDNAME" ]; then
  echo y | civibuild destroy "$BLDNAME"
fi
mkdir "$WORKSPACE/junit"
mkdir "$WORKSPACE/civibuild-html"

## Report details about the test environment
civibuild env-info

## Download application (with civibuild)
civibuild download "$BLDNAME" \
  --civi-ver "$CIVIVER" \
  --type "$BLDTYPE"

## Install application (with civibuild)
civibuild install "$BLDNAME" \
  --admin-pass "n0ts3cr3t"

## Report details about this build of the application
civibuild show "$BLDNAME" \
  --html "$WORKSPACE/civibuild-html" \
  --last-scan "$WORKSPACE/last-scan.json" \
  --new-scan "$WORKSPACE/new-scan.json"
cp "$WORKSPACE/new-scan.json" "$WORKSPACE/last-scan.json"

## Execute tests
SUITES="phpunit-e2e"
civi-test-run -b "$BLDNAME" -j "$WORKSPACE/junit" $SUITES
exit $?

