How to Add a New User
=====================

To add a new shell user with SSH or administration privileges, one must add the user to LDAP. First:

```
ssh -L 7000:localhost:7000 manage.civicrm.osuosl.org
sudo cat /root/ldap-notes.txt
```

After following those instructions, you should be logged into the phpldapadmin. Now:

 * In the left navbar, expand "dc=>civicrm,dc=org" 
 * Expand "ou=people"
 * Choose "Create new entry here" under "ou=people"
 * Choose "Generic: User account"
 * For GID, choose "domainuser"
 * (FIXME: phpldapadmin defaults differ from what we want)

(TODO: for the impatient, reset ldap caches)
(TODO: domainadmin vs local sudo)
