# How to setup a new demo site

The demo sites are constructed when Jenkins periodically calls buildkit's [civibuild](https://github.com/civicrm/civicrm-buildkit/blob/master/doc/civibuild.md) command. Sites follow a naming convention, e.g.

 * _Build description_: Drupal ("d") with CiviCRM 4.4.
 * _Build type / build alias_: d44
 * _URL_: http://d44.demo.civicrm.org

Creating a new demo site falls into a few steps. For this document, we'll assume that you want to add a demo for Drupal with Civi v9.9 ("d99" aka "d99.demo.civicrm.org").

## 1. Make sure there's a build-alias or build-type.

Build aliases are defined in [src/civibuild.aliases.sh](https://github.com/civicrm/civicrm-buildkit/blob/master/src/civibuild.aliases.sh). Build types are defined in [app/config](https://github.com/civicrm/civicrm-buildkit/tree/master/app/config).

If it's not already present, add "d99" to civibuild.aliases.sh. You should probably test the new build-alias locally to ensure that it works:

```bash
civibuild create d99 --url http://d99.localhost
```

Submit and merge any changes to buildkit.

## 2. Deploy latest buildkit

If you've made changes to the build aliases or build types, then:

```
ssh www-demo.civicrm.osuosl.org
sudo -u webeditor -H bash
cd /srv/buildkit
git pull
bin/civi-download-tools
```

## 3. Setup vhost

Make sure DNS for d99.demo.civicrm.org points to the www-demo server.

```bash
nslookup www-demo.civicrm.osuosl.org
nslookup d99.demo.civicrm.org
```

And make vhost files:

```bash
ssh www-demo.civicrm.osuosl.org
sudo bash
cd /etc/apache2/sites-available/
cp {d44,d99}.demo.civicrm.org.offline
cp {d44,d99}.demo.civicrm.org.online
vi d99.demo.civicrm.org.{online,offline}
```

## 4. Configure Jenkins

 * Navigate to [the demo job on test.civicrm.org](https://test.civicrm.org/view/Sites/job/demo.civicrm.org/).
 * Click "Configure"
 * In the BLDNAME axis, add a row for "d99"
 * Save

## 5. (Suggested) Try a manual build

The job on Jenkins should run periodically by itself, but you may want test it manually:

 * Click "Build with parameters"
 * Check "d99". Uncheck everything else.
 * Run the build. Watch the console to make sure it works.
