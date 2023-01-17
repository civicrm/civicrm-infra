#!/bin/bash
set -e

if [ -e $HOME/.profile ]; then . $HOME/.profile; fi
[ -z `which await-bknix` ] || await-bknix "$USER" "dfl"
eval $(use-bknix "dfl")
if [ -z "$BKITBLD" ]; then echo "Invalid BKPROF"; exit 1; fi

## Job Name: CiviCRM-Core-Style
## Job Description: Check that patch has compliant code-style
## Job GitHub Project URL: https://github.com/civicrm/civicrm-core
## Job Source Code Management: None
## Job Triggers: GitHub pull-requests
## Job CheckstyleFiles: WORKSPACE/checkstyle/*.xml
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
BLDTYPE="dist"
BLDNAME="build-$EXECUTOR_NUMBER"
BLDDIR="$BKITBLD/$BLDNAME"
CHECKSTYLEDIR="$WORKSPACE/checkstyle"
EXITCODES=""

#################################################
## Cleanup left-overs from previous test-runs
[ -d "$CHECKSTYLEDIR" ] && $GUARD rm -rf "$CHECKSTYLEDIR"
[ -d "$BLDDIR" ] && $GUARD civibuild destroy "$BLDNAME"
[ ! -d "$CHECKSTYLEDIR" ] && $GUARD mkdir "$CHECKSTYLEDIR"

#################################################
## Report details about the test environment
civibuild env-info

## Download dependencies, apply patches
$GUARD civibuild download "$BLDNAME" --type "$BLDTYPE" --civi-ver "$ghprbTargetBranch" \
  --patch "https://github.com/civicrm/civicrm-core/pull/${ghprbPullId}"

## Check style first; fail quickly if we break style
$GUARD pushd "$BLDDIR/src"
  if git diff --name-only "origin/$ghprbTargetBranch.." | $GUARD civilint --checkstyle "$CHECKSTYLEDIR" - ; then
    echo "Style passed"
  else
    echo "Style error"
    exit 1
  fi
$GUARD popd

