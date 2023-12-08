# LDAP for CiviCRM.org websites

We expose the civicrm.org database as an LDAP server using LdapJS.
This is made possible using the following bits:

* CiviCRM extension: https://github.com/mlutfy/org.civicrm.ldapauthapi
* CiviLDAP forked from: https://github.com/TechToThePeople/ldapcivi (patch: https://gist.github.com/mlutfy/17622c2764472fbf71d0)

## Gitlab

Edit the file `/etc/gitlab/gitlab.rb`, configure:

```
gitlab_rails['ldap_enabled'] = true

gitlab_rails['ldap_servers'] = YAML.load <<-EOS # remember to close this block with 'EOS' below
main:
  label: 'civicrm.org'
  host: 'civicrm.org'
  port: 1389
  uid: 'uid'
  method: 'ssl' # "tls" or "ssl" or "plain"

  bind_dn: 'dc=civicrm,dc=org'
  password: '[... PASSWORD from config/civicrm.js ...]'

  # Set a timeout, in seconds, for LDAP queries.
  timeout: 10

  # For non AD servers it skips the AD specific queries.
  # If your LDAP server is not AD, set this to false.
  active_directory: false

  # If allow_username_or_email_login is enabled, GitLab will ignore everything
  # after the first '@' in the LDAP username submitted by the user on login.
  #
  # Example:
  # - the user enters 'jane.doe@example.com' and 'p@ssw0rd' as LDAP credentials;
  # - GitLab queries the LDAP server with 'jane.doe' and 'p@ssw0rd'.
  #
  # If you are using "uid: 'userPrincipalName'" on ActiveDirectory you need to
  # disable this setting, because the userPrincipalName contains an '@'.
  allow_username_or_email_login: false

  # To maintain tight control over the number of active users on your GitLab installation,
  # enable this setting to keep new users blocked until they have been cleared by the admin
  # (default: false).
  block_auto_created_users: false

  # Filter LDAP users
  user_filter: ''

  # LDAP attributes that GitLab will use to create an account for the LDAP user.
  # The specified attribute can either be the attribute name as a string (e.g. 'mail'),
  # or an array of attribute names to try in order (e.g. ['mail', 'email']).
  # Note that the user's LDAP login will always be the attribute specified as `uid` above.
  attributes:
    # The username will be used in paths for the user's own projects
    # (like `gitlab.example.com/username/project`) and when mentioning
    # them in issues, merge request and comments (like `@username`).
    # If the attribute specified for `username` contains an email address,
    # the GitLab username will be the part of the email address before the '@'.
    username: ['uid', 'userid', 'sAMAccountName']
    email:    ['mail', 'email', 'userPrincipalName']

    # If no full name could be found at the attribute specified for `name`,
    # the full name is determined using the attributes specified for
    # `first_name` and `last_name`.
    name:       'cn'
    first_name: 'givenName'
    last_name:  'sn'
EOS
```

## Debugging LDAP auth

* Make sure that the `ldapcivi` service is running on www-prod-2 (it is monitored) and that the https cert is valid (also monitored)
* Look for logs on www-prod-2 using `tail -F /var/log/nginx/error.log`
* Look for logs on www-prod-2 using `journalctl -f -u ldapcivi` (the ldapcivi services logs to stderr and it is very verbose)

Testing on the command line, from lab.civicrm.org, using a test account (bgmtest) and the password for that user, should return something like the output below. This can help avoid getting banned from too many attempts on Gitlab.

```
root@lab:~# ldapsearch -H ldaps://civicrm.org:1389 -x -D cn=bgmtest,dc=civicrm,dc=org -W -b dc=civicrm,dc=org uid=bgmtest  \*
Enter LDAP Password:
[...]
# bgmtest, civicrm.org
dn: cn=bgmtest, dc=civicrm, dc=org
objectClass: top
objectClass: inetOrgPerson
objectClass: person
gidNumber: 999
cn: bgmtest
posixAcccount: bgmtest
uid: bgmtest

# search result
search: 2
result: 0 Success

# numResponses: 2
# numEntries: 1
```

## Confluence (deprecated)

(we do not use this anymore, we keep this doc just for reference, might help for other software)

* Go to Space > Administration, then from the menu click on "User Directories".
* Click on "Add directory", select "type = LDAP".

Parameters:

* Name: civicrm.org
* Type: OpenLDAP (Read-Only Posix Schema)
* Host: civicrm.org
* Port: 1389, ✔ use SSL
* User: dc=civicrm,dc=org
* Password: see settings.ldap.password in config/civicrmorg.js on www-prod.
* Base DN: dc=civicrm,dc=org
* LDAP Authorizations: Read-only, with local groups.
* LDAP Authorizations: Default group: confluence-users
* Schema options: LDAP username RDN: cn
* Schema options: Password encoding: plaintext
