#!/bin/bash

# Helps apply a CiviCRM github pull-request.
# Based on a script by @litespeedmarc

if [ $# -ne 1 ]
then
  echo "Invalid syntax.  Syntax is $0 <PR> <platform-path>"
  echo "  where PR is the numeric PR and platform-path defaults to the current working directory (should be the platform root)"
  echo "  Patches will be saved in the civicrm-patches directory."
  exit 1
fi

PATCH_NUMBER=$1
PLATFORMROOT=$PWD

if [ -z "$PLATFORMROOT" ]; then
  PLATFORMROOT="/var/aegir/platforms/civicrm-d8"
fi

echo "Using platform in $PLATFORMROOT .."
echo "Parsing title from PR # $PATCH_NUMBER .."

# FIXME: Remove CRM-XXXX check and detect dev/foo#1234
ISSUENUMBER=`curl -s https://api.github.com/repos/civicrm/civicrm-core/issues/$PATCH_NUMBER | php -r '$t = json_decode(file_get_contents("php://stdin"), TRUE); $title = preg_replace("/.*(CRM-\d+).*/", "$1", $t["title"]); $title = preg_replace("/[^-_a-zA-Z0-9]/", "_", $title); echo $title;'`
echo "Patch title is: $ISSUENUMBER .."

export PATCH_FILENAME=`date +%Y%m%d`_PR${PATCH_NUMBER}_${ISSUENUMBER}.patch
export PATCH_FILE=$PLATFORMROOT/civicrm-patches/$PATCH_FILENAME

echo "Downloading PR to $PATCH_FILENAME .."
curl -s https://patch-diff.githubusercontent.com/raw/civicrm/civicrm-core/pull/$PATCH_NUMBER.patch > $PATCH_FILE

echo "Testing whether the patch can be applied .."
cd $PLATFORMROOT

if [ -d "$PLATFORMROOT/vendor/civicrm/civicrm-core" ]; then
  git apply --check --verbose --directory vendor/civicrm/civicrm-core/ $PATCH_FILE
else
  git apply --check --verbose --directory sites/all/modules/civicrm/ $PATCH_FILE
fi

echo ""
echo "You can now apply the patch using this command: "
echo "First to check: "
echo git apply --verbose --directory sites/all/modules/civicrm/ --check $PATCH_FILE
echo ""
echo "Then to apply:"
echo git apply --verbose --directory sites/all/modules/civicrm/ $PATCH_FILE
echo ""
