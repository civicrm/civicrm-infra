How to setup a new demo on jenkins
======================================
TODO: We should setup up demos on the www-demo server -- and let jenkins handle the resets.

Lets say we want to create a new demo (e.g civihr.demo.civicrm.org) similar to an existing job (e.g civihr-auto.dev.civicrm.org). 
(Note: We will proceed with civihr.demo example but the steps can be applied to any demo you might want to create.)

Login to test.civicrm.org

Create a "new job" (e.g civihr.demo.civicrm.org) and use "copy existing job" (e.g civihr-auto.dev.civicrm.org) option if new job is similar to an existing one.

On configure screen: Specify the node/slave as "Label Expression". This is generally auto populated if you have copied from an existing job.

Configure "Source Code Management"
```
Use "Multiple SCMs" option to say specify git repos:

Add git repo for core civicrm
Set Repository URL - e.g git://github.com/civicrm/civicrm-core.git
Set Branch Specifier - e.g 4.4
Specify Local subdirectory for repo - e.g civicrm

Add another git repo for say drupal 
Set Repository URL - e.g git://github.com/civicrm/civicrm-drupal.git
Set Branch Specifier - e.g 7.x-4.4
Specify Local subdirectory for repo - e.g civicrm/drupal

Add another git repo for say packages
Set Repository URL - e.g git://github.com/civicrm/civicrm-packages.git
Set Branch Specifier - e.g 4.4
Specify Local subdirectory for repo - e.g civicrm/packages

Add another git repo for civihr extension
Set Repository URL - e.g https://github.com/civicrm/civihr.git
Set Branch Specifier - e.g 1.0
Specify Local subdirectory for repo - e.g civicrm/tools/extensions/civihr
```

Configure "build triggers"
```
Use "Build periodically" and "Poll SCM" options.
```

Configure "Build"
```
Use "Execute Shell" option to write down a bash script which basically:
puts site in offline mode
builds a drupal site along with civicrm
install extension of required
put the site back on.

If you have copied from an existing job, this section should be prepopulated and can be tweaked as required.
```

The script should mostly configure the site per requirements. However in case you need to access UI to do some configuration, you might want to save a pristine copy of DB (on www-demo) and adjust the script to load it.

Click save.

Log in to the node (e.g www-demo) to make sure apache conf file used in the script, exist. If not manually copy and create from an existing one.

Make sure DNS points to the site being rebuilt.
