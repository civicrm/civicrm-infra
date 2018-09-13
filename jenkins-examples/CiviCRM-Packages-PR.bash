#!/bin/bash
set -e

if [ -e $HOME/.profile ]; then . $HOME/.profile; fi
eval $(use-bknix "dfl")
if [ -z "$BKITBLD" ]; then echo "Invalid BKPROF"; exit 1; fi

## Job Name: CiviCRM-Packages-PR
## Job Description: Monitor civicrm-packages.git for proposed changes
##    For any proposed changes, run a few "smoke tests"
## Job GitHub Project URL: https://github.com/civicrm/civicrm-packages
## Job Source Code Management: None
## Job Triggers: GitHub pull-requests
## Job xUnit Files: WORKSPACE/output/*.xml
## Useful vars: $ghprbTargetBranch, $ghprbPullId, $sha1
## Pre-requisite: Install civicrm-buildkit; configure amp
## Pre-requisite: Configure DNS and Apache vhost to support wildcards (e.g. *.test-ubu1204-5.civicrm.org)

## Pre-requisite: We only test PR's for main-line branches.

case "$ghprbTargetBranch" in
  4.6*|4.7*|5*|master*)
    CIVIVER="$ghprbTargetBranch"
    ;;
  #4.6*)
  #  echo "PR test not allowed for $ghprbTargetBranch"
  #  exit 0
  #  ;;
  *)
    ## This actually true for many branches, so we exit softly...
    echo "PR test not allowed for $ghprbTargetBranch"
    exit 1
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
BLDTYPE="drupal-clean"
BLDNAME="pkg-$ghprbPullId-$(php -r 'echo base_convert(time()%(180*24*60*60), 10, 36);')"
BLDDIR="$BKITBLD/$BLDNAME"
JUNITDIR="$WORKSPACE/junit"

#################################################
## Download dependencies, apply patches, and perform fresh DB installation
$GUARD civibuild download "$BLDNAME" --type "$BLDTYPE" --civi-ver "$CIVIVER" \
  --patch "https://github.com/civicrm/civicrm-packages/pull/${ghprbPullId}"

$GUARD civibuild install "$BLDNAME"

## Run the tests
$GUARD civi-test-run -b "$BLDNAME" -j "$JUNITDIR" all
exit $?
