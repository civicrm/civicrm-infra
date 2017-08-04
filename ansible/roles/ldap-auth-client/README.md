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
* `/etc/nsswitch.conf` should have:

```
passwd:         compat  ldap
group:          compat  db
shadow:         compat  db
gshadow:        files
```

