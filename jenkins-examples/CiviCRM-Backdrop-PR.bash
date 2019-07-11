#!/bin/bash
set -e

if [ -e $HOME/.profile ]; then . $HOME/.profile; fi
eval $(use-bknix "dfl")
if [ -z "$BKITBLD" ]; then echo "Invalid BKPROF"; exit 1; fi

## Job Name: CiviCRM-Backdrop-PR
## Job Description: Monitor civicrm-backdrop.git for proposed changes
##    For any proposed changes, run a few "smoke tests"
## Job GitHub Project URL: https://github.com/civicrm/civicrm-backdrop
## Job Source Code Management: None
## Job Triggers: GitHub pull-requests
## Job xUnit Files: WORKSPACE/output/*.xml
## Useful vars: $ghprbTargetBranch, $ghprbPullId, $sha1
## Pre-requisite: Install civicrm-buildkit; configure amp
## Pre-requisite: Configure DNS and Apache vhost to support wildcards (e.g. *.test-ubu1204-5.civicrm.org)

## Pre-requisite: We only test PR's for main-line branches.

case "$ghprbTargetBranch" in
  1.x-4.6*|1.x-4.7*|1.x-5*|1.x-master*)
    CIVIVER=$(echo "$ghprbTargetBranch" | sed 's;^1.x-;;')
    ;;
  *)
    ## This actually true for many branches, so we exit softly...
    echo "PR test not allowed for $ghprbTargetBranch"
    exit 0
    ;;
esac

#################################################
## Inputs; if called manually, use some defaults
EXECUTOR_NUMBER=${EXECUTOR_NUMBER:-9}
WORKSPACE=${WORKSPACE:-/var/lib/jenkins/workspace/Foo/Bar}

## Environment
GUARD=

## Build definition
## Note: Suffixes are unique within a period of 180 days.
BLDTYPE="backdrop-clean"
BLDNAME="bd-$ghprbPullId-$(php -r 'echo base_convert(time()%(180*24*60*60), 10, 36);')"
BLDDIR="$BKITBLD/$BLDNAME"
JUNITDIR="$WORKSPACE/junit"
CHECKSTYLEDIR="$WORKSPACE/checkstyle"
EXITCODES=""

#################################################
## Cleanup left-overs from previous test-runs
[ -d "$CHECKSTYLEDIR" ] && $GUARD rm -rf "$CHECKSTYLEDIR"
[ -d "$BLDDIR" ] && $GUARD civibuild destroy "$BLDNAME"
[ ! -d "$CHECKSTYLEDIR" ] && $GUARD mkdir "$CHECKSTYLEDIR"

#################################################
## Download dependencies, apply patches, and perform fresh DB installation
$GUARD civibuild download "$BLDNAME" --type "$BLDTYPE" --civi-ver "$CIVIVER" \
  --patch "https://github.com/civicrm/civicrm-backdrop/pull/${ghprbPullId}"

## Check style first; fail quickly if we break style
$GUARD pushd "$BLDDIR/web/modules/civicrm/backdrop"
  case "$ghprbTargetBranch" in
    1.x-4.3*|1.x-4.4*|1.x-4.5*|1.x-4.6*)
      ## skip
      ;;
    *)
      if git diff --name-only "origin/$ghprbTargetBranch.." | $GUARD civilint --checkstyle "$CHECKSTYLEDIR" - ; then
        echo "Style passed"
      else
        echo "Style error"
        exit 1
      fi
  esac
$GUARD popd

$GUARD civibuild install "$BLDNAME"

## Run the tests
echo civi-test-run -b "$BLDNAME" -j "$JUNITDIR" phpunit-e2e
$GUARD civi-test-run -b "$BLDNAME" -j "$JUNITDIR" phpunit-e2e
exit $?
