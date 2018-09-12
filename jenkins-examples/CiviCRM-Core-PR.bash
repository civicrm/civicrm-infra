#!/bin/bash
set -e

if [ -e $HOME/.profile ]; then . $HOME/.profile; fi

## Job Name: CiviCRM-Core-PR
## Job Description: Monitor civicrm-core.git for proposed changes
##    For any proposed changes, run a few "smoke tests"
## Job GitHub Project URL: https://github.com/civicrm/civicrm-core
## Job Source Code Management: None
## Job Triggers: GitHub pull-requests
## Job xUnit Files: WORKSPACE/output/*.xml
## Useful vars: $ghprbTargetBranch, $ghprbPullId, $sha1
## Pre-requisite: Install civicrm-buildkit; configure amp
## Pre-requisite: Configure DNS and Apache vhost to support wildcards (e.g. *.test-ubu1204-5.civicrm.org)

## Pre-requisite: We only test PR's for main-line branches.
case "$ghprbTargetBranch" in
  4.*|5.*|master*)
    CIVIVER=$ghprbTargetBranch
    ;;
  *)
    echo "PR test not allowed for $ghprbTargetBranch"
    exit 1
    ;;
esac

#################################################
## Inputs; if called manually, use some defaults
EXECUTOR_NUMBER=${EXECUTOR_NUMBER:-9}
WORKSPACE=${WORKSPACE:-/var/lib/jenkins/workspace/Foo/Bar}

## Environment
BLDKIT="${BLDKIT:-/home/jenkins/buildkit}"
PATH="$BLDKIT/bin:$PATH"
GUARD=

## Build definition
## Note: Suffixes are unique within a period of 180 days.
BLDTYPE="drupal-clean"
BLDNAME="core-$ghprbPullId-$(php -r 'echo base_convert(time()%(180*24*60*60), 10, 36);')"
BLDURL="http://$BLDNAME.test-ubu1204-5.civicrm.org"
BLDDIR="$BLDKIT/build/$BLDNAME"
JUNITDIR="$WORKSPACE/junit"
CHECKSTYLEDIR="$WORKSPACE/checkstyle"
EXITCODES=""

#################################################
## Helpers
function fatal() {
  echo "$@"
  exit 1
}

#################################################
## Cleanup left-overs from previous test-runs
[ -d "$JUNITDIR" ] && $GUARD rm -rf "$JUNITDIR"
[ -d "$CHECKSTYLEDIR" ] && $GUARD rm -rf "$CHECKSTYLEDIR"
[ -d "$BLDDIR" ] && $GUARD civibuild destroy "$BLDNAME"
[ ! -d "$JUNITDIR" ] && $GUARD mkdir "$JUNITDIR"
[ ! -d "$CHECKSTYLEDIR" ] && $GUARD mkdir "$CHECKSTYLEDIR"

#################################################
## Download dependencies, apply patches, and perform fresh DB installation
$GUARD civibuild download "$BLDNAME" --type "$BLDTYPE" --civi-ver "$CIVIVER"  --url "$BLDURL" \
  --patch "https://github.com/civicrm/civicrm-core/pull/${ghprbPullId}"

## Check style first; fail quickly if we break style
$GUARD pushd "$BLDDIR/sites/all/modules/civicrm"
  case "$ghprbTargetBranch" in
    4.3*)
      ## skip
      ;;
    4.4*)
      ## skip
      ;;
    4.5*)
      ## skip
      ;;
    *)
      if git diff --name-only "origin/$ghprbTargetBranch.." | $GUARD $OLDPHP civilint --checkstyle "$CHECKSTYLEDIR" - ; then
        echo "Style passed"
      else
        echo "Style error"
        exit 1
      fi
  esac
$GUARD popd

$GUARD civibuild install "$BLDNAME"

## Run the tests -- Javascript
$GUARD pushd "$BLDDIR/sites/all/modules/civicrm"
  ## Work-around: ensure pradmin user has sa contact
  drush -u pradmin cvapi contact.get id=user_contact_id
  if [ -f karma.conf.js ]; then
    if ! $GUARD karma start --browsers PhantomJS --single-run --reporters dots,junit ; then
      EXITCODES="$EXITCODES karma"
    fi
    $GUARD cp tests/output/karma.xml "$JUNITDIR/"
  fi
$GUARD popd

## Run the tests -- DB upgrade tests
case "$CIVIVER" in
  4.3*)    UTVERS="4.2.9-multilingual_af_bg_en.mysql.bz2 4.3.0*" ;;
  4.4*)    UTVERS="4.2.9-multilingual_af_bg_en.mysql.bz2 4.3.0* 4.4.0*" ;;
  4.5*)    UTVERS="4.2.9-multilingual_af_bg_en.mysql.bz2 4.3.0* 4.4.0* 4.5.0*" ;;
  4.6*)    UTVERS="4.2.9-multilingual_af_bg_en.mysql.bz2 4.3.0* 4.4.0* 4.5.0* 4.6.0*" ;;
  4.7*)    UTVERS="4.2.9-multilingual_af_bg_en.mysql.bz2 4.4.0* 4.5.0* 4.6.0* 4.7.0*" ;;
  5*|master*) UTVERS="4.2.9-multilingual_af_bg_en.mysql.bz2 4.4.0* 4.5.0* 4.6.0* 4.7.0*" ;;
  *)      echo "UpgradeTest failed: Unrecognized version ($CIVIVER)" ; exit 1; ;;
esac
if ! $GUARD civibuild upgrade-test $BLDNAME $UTVERS ; then
  EXITCODES="$EXITCODES upgrade-test"
fi
$GUARD cp "$BLDKIT/app/debug/$BLDNAME/civicrm-upgrade-test.xml" "$JUNITDIR/"
$GUARD civibuild restore "$BLDNAME"

## Run the tests -- unit tests
if [ -f "$BLDDIR/sites/all/modules/civicrm/tests/phpunit/E2E/AllTests.php" ]; then
  if ! $GUARD phpunit-each --exclude-group ornery "$BLDDIR/sites/all/modules/civicrm" "$JUNITDIR" E2E_AllTests ; then
    EXITCODES="$EXITCODES phpunit"
  fi
  $GUARD civibuild restore "$BLDNAME"
fi

if ! $GUARD phpunit-each --exclude-group ornery "$BLDDIR/sites/all/modules/civicrm" "$JUNITDIR" CRM_AllTests api_v3_AllTests Civi\\AllTests ; then
  EXITCODES="$EXITCODES phpunit"
fi

phpunit-xml-cleanup "$JUNITDIR"/*.xml

## Check test results and set exit code
echo "Check test results and set exit code"
cat "$JUNITDIR"/*.xml | grep '<failure' -q && fatal "Found <failure> in XML"
cat "$JUNITDIR"/*.xml | grep '<error' -q && fatal "Found <error> in XML"
[ ! -f "$JUNITDIR/civicrm-upgrade-test.xml" ] && fatal "Missing XML: civicrm-upgrade-test.xml"
[ ! -f "$JUNITDIR/api_v3_AllTests.xml" ] && fatal "Missing XML: api_v3_AllTests.xml"
[ ! -f "$JUNITDIR/CRM_AllTests.xml" ] && fatal "Missing XML: CRM_AllTests.xml"
[ -d "$BLDDIR/sites/all/modules/civicrm/tests/karma" -a ! -f "$JUNITDIR/karma.xml" ] && fatal "Missing XML: karma.xml"
[ -n "$EXITCODES" ] && fatal "At least one command failed abnormally [$EXITCODES]"
echo "Exit normally"
