#!/bin/bash
set -e

if [ -e $HOME/.profile ]; then . $HOME/.profile; fi
eval $(use-bknix "dfl")
if [ -z "$BKITBLD" ]; then echo "Invalid BKPROF"; exit 1; fi

## Job Name: CiviCRM-Core-PR
## Job Description: Monitor civicrm-core.git for proposed changes
##    For any proposed changes, run a few "smoke tests"
## Job GitHub Project URL: https://github.com/civicrm/civicrm-core
## Job Source Code Management: None
## Job Triggers: GitHub pull-requests
## Job xUnit Files: WORKSPACE/output/*.xml
## Useful vars: $ghprbTargetBranch, $ghprbPullId, $sha1
## Pre-requisite: Install bknix (install-ci.sh)
## Pre-requisite: Configure DNS and Apache vhost to support wildcards (e.g. *.test-ubu1204-5.civicrm.org)

#################################################
## Pre-requisite: We only test PR's for main-line branches.
case "$ghprbTargetBranch" in
  4.6*|4.7*|5.*|master*) echo "PR test is supported for $ghprbTargetBranch" ;;
  *)                     echo "PR test not supported for $ghprbTargetBranch" ; exit 1 ;;
esac

#################################################
## Inputs; if called manually, use some defaults
EXECUTOR_NUMBER=${EXECUTOR_NUMBER:-9}
WORKSPACE=${WORKSPACE:-/var/lib/jenkins/workspace/Foo/Bar}
GUARD=

## Build definition
## Note: Suffixes are unique within a period of 180 days.
BLDTYPE="drupal-clean"
BLDNAME="core-$ghprbPullId-$(php -r 'echo base_convert(time()%(180*24*60*60), 10, 36);')"
BLDDIR="$BKITBLD/$BLDNAME"
JUNITDIR="$WORKSPACE/junit"
CHECKSTYLEDIR="$WORKSPACE/checkstyle"
EXITCODES=""

#################################################
## Cleanup left-overs from previous test-runs
[ -d "$JUNITDIR" ] && $GUARD rm -rf "$JUNITDIR"
[ -d "$CHECKSTYLEDIR" ] && $GUARD rm -rf "$CHECKSTYLEDIR"
[ -d "$BLDDIR" ] && $GUARD civibuild destroy "$BLDNAME"
[ ! -d "$JUNITDIR" ] && $GUARD mkdir "$JUNITDIR"
[ ! -d "$CHECKSTYLEDIR" ] && $GUARD mkdir "$CHECKSTYLEDIR"

#################################################
## Download dependencies, apply patches, and perform fresh DB installation
$GUARD civibuild download "$BLDNAME" --type "$BLDTYPE" --civi-ver "$ghprbTargetBranch" \
  --patch "https://github.com/civicrm/civicrm-core/pull/${ghprbPullId}"

## Check style first; fail quickly if we break style
$GUARD pushd "$BLDDIR/web/sites/all/modules/civicrm"
  if git diff --name-only "origin/$ghprbTargetBranch.." | $GUARD civilint --checkstyle "$CHECKSTYLEDIR" - ; then
    echo "Style passed"
  else
    echo "Style error"
    ## TODO: Restore simpler logic after April 2019
    # exit 1
    [ "$ghprbTargetBranch" = "5.12" ] || exit 1
  fi
$GUARD popd

## No obvious problems blocking a build...
$GUARD civibuild install "$BLDNAME"

## Run the tests
civi-test-run -b "$BLDNAME" -j "$JUNITDIR" \
  --exclude-group ornery \
  karma upgrade phpunit-e2e phpunit-civi phpunit-crm phpunit-api
