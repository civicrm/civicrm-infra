# Sympa Mailing List Integration

One may use CiviCRM to manage a list of subscribers in a Sympa mailing list.

The following mailing lists should be integrated:

 * `civicrm-test-public@lists.civicrm.org` => Group 347 (civicrm-test-public)

# How To

## Step 1. Create a static group

Use normal civicrm.org UI. Note the GID#.

## Step 2. Create MySQL view and user

(Note: The following example uses some valeues which should be customized; e.g.
gid `12345` and view `sympa_test_public` and the username/password.)

```sql
CREATE VIEW sympa_test_public AS
SELECT e.email
FROM civicrm_group g
INNER JOIN civicrm_group_contact gc on gc.group_id = g.id
INNER JOIN civicrm_email e on gc.contact_id = e.contact_id
WHERE g.id=12345 AND gc.status = 'Added' AND e.is_primary = 1 AND e.on_hold = 0;

GRANT USAGE, SELECT ON co_civicrm.sympa_test_public TO 'sympa_lists'@'%' IDENTIFIED BY 'topsecret';
```

## Step 3. Create a Sympa mailing list

Go to lists.civicrm.org and "Create Group". Fill out the form.

Go to "Manage Group => Change Settings => Data sources". Fill in the connection details. For the SQL query, use `SELECT email FROM sympa_test_public`
(or whichever view you crated).

TODO: Customize footer for unsubscribe instructions
