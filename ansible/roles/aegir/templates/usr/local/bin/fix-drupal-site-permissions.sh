#!/bin/bash

# {{ ansible_managed }}

# Help menu
print_help() {
cat <<-HELP
This script is used to fix the file permissions of a Drupal site. You need
to provide the following argument:

  --site-path: Path to the Drupal site's directory.

Usage: (sudo) ${0##*/} --site-path=PATH
Example: (sudo) ${0##*/} --site-path=/var/aegir/platforms/drupal-7.50/sites/example.com
HELP
exit 0
}

if [ $(id -u) != 0 ]; then
  printf "Error: You must run this with sudo or root.\n"
  exit 1
fi

site_path=${1%/}

# Parse Command Line Arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    --site-path=*)
        site_path="${1#*=}"
        ;;
    --help) print_help;;
    *)
      printf "Error: Invalid argument, run --help for valid arguments.\n"
      exit 1
  esac
  shift
done

if [ -z "${site_path}" ] || [ ! -f "${site_path}/settings.php" ] ; then
  printf "Error: Please provide a valid Drupal site directory.\n"
  exit 1
fi

cd $site_path

printf "Changing permissions of all directories inside \"${site_path}\" to \"750\"...\n"
find . \( -path "./files" -o -path "./private" -prune \) -type d -exec chmod 750 '{}' \+

printf "Changing permissions of all files inside \"${site_path}\" to \"640\"...\n"
find . \( -path "./files" -o -path "./private" -prune \) -type f -exec chmod 640 '{}' \+

printf "Changing permissions of \"files\" directory in \"${site_path}/sites\" to \"770\"...\n"
chmod 770 files

printf "Changing permissions of all files inside \"files\" directory in \"${site_path}\" to \"660\"...\n"
find ./files -type f -exec chmod 660 '{}' \+

printf "Changing permissions of all directories inside \"files\" directory in \"${site_path}\" to \"770\"...\n"
find ./files -type d -exec chmod 770 '{}' \+

printf "Changing permissions of \"private\" directory in \"${site_path}/sites\" to \"770\"...\n"
chmod 770 private

printf "Changing permissions of all files inside \"private\" directory in \"${site_path}\" to \"660\"...\n"
find ./private -type f -exec chmod 660 '{}' \+

printf "Changing permissions of all directories inside \"private\" directory in \"${site_path}\" to \"770\"...\n"
find ./private -type d -exec chmod 770 '{}' \+

# SYMBIOTIC additions for
# https://www.drupal.org/project/hosting_civicrm/issues/2972031
if [ -d ./files/civicrm/templates_c ]; then
  printf "Changing permissions of all directories inside \"templates_c\" directory in \"${site_path}\" to \"2770\" (setgid)...\n"
  find ./files/civicrm/templates_c -type d -exec chmod 02770 '{}' \+

  printf "Changing permissions of all directories inside \"ConfigAndLog\" directory in \"${site_path}\" to \"2770\" (setgid)...\n"
  find ./files/civicrm/ConfigAndLog -type d -exec chmod 02770 '{}' \+
fi

# SYMBIOTIC additions to ensure that PHP files are not web-writable
printf "Changing permissions of all directories inside \"modules\" directory in \"${site_path}\" to \"0755\"...\n"
find ./modules -type d -exec chmod 0755 '{}' \+
find ./modules -type d -exec chmod g-s '{}' \+

printf "Changing permissions of all files inside \"modules\" directory in \"${site_path}\" to \"0644\"...\n"
find ./modules -type f -exec chmod 0644 '{}' \+

printf "Changing permissions of all directories inside \"themes\" directory in \"${site_path}\" to \"0755\"...\n"
find ./themes -type d -exec chmod 0755 '{}' \+
find ./themes -type d -exec chmod g-s '{}' \+

printf "Changing permissions of all files inside \"themes\" directory in \"${site_path}\" to \"0644\"...\n"
find ./themes -type f -exec chmod 0644 '{}' \+

# this should be in fix-ownership, but we haven't overriden it yet
find ./modules -exec chown aegir.aegir '{}' \+
find ./themes -exec chown aegir.aegir '{}' \+

echo "Done setting proper permissions on site files and directories."
