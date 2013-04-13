How to Add a New User
=====================

To add a new shell user with SSH or administration privileges, one must add
the user to LDAP.  First, connect to the LDAP administrative interface:

```
ssh -L 7000:localhost:7000 manage.civicrm.osuosl.org
sudo cat /root/ldap-notes.txt
```

The text file provides additional instructions. Once the LDAP web interface is open:

 * In the left navbar, expand "dc=civicrm,dc=org"
 * Expand "ou=people"
 * Choose "Create new entry here" under "ou=people"
 * Choose "Generic: User account"
 * Complete the form. Some notes on specific fields:
   * Common name: Should be the full name
   * GID: choose "domainuser"
   * Shell: choose /bin/bash
   * User ID and Home: Make sure these match (e.g. user ID "dave" corresponds to home directory "/home/dave")

After creating the user in phpldapadmin, the user ID will become valid on
all VMs within 10 minutes.  (Each VM maintains a cached list of users and
groups -- this improves performance and improves robustness against LDAP
failures but delays propagation of new usernames.)

The new user does not have permission to login or administer any systems. Do
one of the following (as appropriate):

  * To grant SSH+sudo access on all VMs:
    * In the left navbar, expand "dc=civicrm,dc=org"
    * Expand "ou=groups"
    * Choose "cn=domainadmin"
    * Under the memberUid, choose "modify group members"
    * Add the new user and save
  * To grant SSH+sudo access to one specific VM:
    * Login to the target VM via SSH
    * Run "sudo nss_updatedb ldap" (Note: This step is run automatically every ~10min. Manual invocation is only necessary if you're impatient.)
    * Run "sudo adduser sudo"
  * To grant SSH access (but NOT sudo access) to one specific VM:
    * Login to the target VM via SSH
    * Run "sudo nss_updatedb ldap" (Note: This step is run automatically every ~10min. Manual invocation is only necessary if you're impatient.)
    * Run "sudo adduser ssh-user"
