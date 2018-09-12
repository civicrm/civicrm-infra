#!/bin/bash
set -ex

if [ -e $HOME/.profile ]; then . $HOME/.profile; fi

## Job Name: CiviCRM-Core-Matrix
## Job Description: Periodically run the unit tests on all major
##   major branches of civicrm-core.git
## Job GitHub Project URL: https://github.com/civicrm/civicrm-core
## Job Source Code Management: None
## Job Triggers: Scheduled
## Job xUnit Files: WORKSPACE/junit/*.xml
## Useful vars: $CIVIVER (e.g. "4.5", "4.6", "master")
## Pre-requisite: Install civicrm-buildkit; configure amp
## Pre-requisite: Configure /etc/hosts and Apache with "build-1.l", "build-2.l", ..., "build-6.l"

BUILDKIT="/srv/buildkit"
BLDNAME="build-$EXECUTOR_NUMBER"
BLDURL="http://build-$EXECUTOR_NUMBER.l"
EXITCODE=0

export PATH="$BUILDKIT/bin:$PATH"
#if [ -d "/opt/php/5.4.45/bin" -a "$CIVIVER" != "4.6" ]; then export PATH="/opt/php/5.4.45/bin:$PATH"; fi

## Reset (cleanup after previous tests)
[ -d "$WORKSPACE/junit" ] && rm -rf "$WORKSPACE/junit"
[ -d "$WORKSPACE/civibuild-html" ] && rm -rf "$WORKSPACE/civibuild-html"
if [ -d "/srv/buildkit/build/$BLDNAME" ]; then
  echo y | civibuild destroy "$BLDNAME"
fi
mkdir "$WORKSPACE/junit"
mkdir "$WORKSPACE/civibuild-html"

## Download application (with civibuild)
civibuild download "$BLDNAME" \
  --civi-ver "$CIVIVER" \
  --type "drupal-clean"

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

## Detect & execute tests
pushd "/srv/buildkit/build/$BLDNAME/sites/all/modules/civicrm"
  SUITES="phpunit-crm phpunit-api phpunit-civi upgrade"

  if [ -f "tests/phpunit/E2E/AllTests.php" ]; then
    SUITES="$SUITES phpunit-e2e"
  else
    echo "Skip unavailable suite: phpunit-e2e"
  fi

  if [ -f "karma.conf.js" ]; then
    SUITES="$SUITES karma"
  else
    echo "Skip unavailable suite: karma"
  fi
popd

civi-test-run -b "$BLDNAME" -j "$WORKSPACE/junit" $SUITES
exit $?
