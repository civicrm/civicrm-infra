LDAP client
===========

This documentation is specific to the CiviCRM-org infrastructure.

How to test LDAP
----------------

```
$ ldapsearch -v -H ldaps://manage.civicrm.osuosl.org/ -D uid=USERNAME,ou=people,dc=civicrm,dc=org -W -x -b dc=civicrm,dc=org -d1
```

(where `USERNAME` is your username)

```
$ getent passwd [username]
```

(where `[username]` is an actual username). This should return an entry equivalent to those found in `passwd`.

A few things to keep an eye on
------------------------------

(some of these might be wrong, since I constantly get confused by LDAP --bgm)

* The `libnss-ldap` should be installed
  * its configuration is in `/etc/libnss-ldap.conf`

If `/etc/nsswitch.conf` has:

```
passwd:         compat  db 
group:          compat  db 
shadow:         compat  db 
```

.. then it is using `nss_updatedb`, which stores a cache of credentials in `/var/lib/misc/{passwd,group}.db`. A cron tab run  `nss_updatedb` every ... minutes/hours to update the cache. This makes it possible to continue using LDAP even if the LDAP server is completely offline.

A best of both worls might be to use:

```
passwd:         files ldap [NOTFOUND=return] db
group:          files ldap [NOTFOUND=return] db
shadow:         files ldap [NOTFOUND=return] db
```

This uses the LDAP server if it is availalbe, and if not, the local cache. (ref)[https://help.ubuntu.com/community/PamCcredsHowto]. The `[NOTFOUND=return]` directive means that if the LDAP server did respond that the user does not exist, then it does not look further.
