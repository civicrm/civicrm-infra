# Demo sites

All demo sites are built with buildkit (https://github.com/civicrm/civicrm-buildkit).  For example, “d44.demo.civicrm.org” is just “civibuild d44 —url d44.demo.civicrm.org”.

Demo sites are rebuilt nightly. The rebuilds are triggered via https://test.civicrm.org/view/Sites/job/demo.civicrm.org/.

## Updating build scripts

If there's been a change to the build scripts in `civicrm-buildkit`, then you may need to update by those by hand.

```
ssh www-demo.civicrm.osuosl.org
sudo -u webeditor -H bash
cd /srv/buildkit/
git pull
./bin/civi-download-tools
```

## Ad hoc rebuild of a demo site

Useful when it has been trashed too much and you cannot wait 24 hours.

* navigate to https://test.civicrm.org/view/Sites/job/demo.civicrm.org/ and
* choose “Build with Parameters” and check/uncheck the target sites.

If a rebuild fails, it will usually roll back and restore the old build.

## Trouble shooting demo sites

If all demo sites are unresponsive, try a normal apache restart on www-demo.civicrm.osuosl.org

```
sudo service apache2 restart

```
