Hosts
=====

<table>
  <thead>
    <tr>
      <th>Host</th>
      <th>Type</h>
      <th>OS</th>
      <th>IP</th>
      <th>Comments</th>
    </tr>
  </thead>
  <tbody>
      <tr>
      <td>biryani</td>
      <td>Physical</td>
      <td>Ubuntu 10.4 LTS (Lucid Lynx)</td>
      <td>X</td>
      <td>Smorgasbord</td>
    </tr>
    <tr>
      <td>sushi</td>
      <td>Physical</td>
      <td>Ubuntu 8.04 LTS (Hardy Heron)</td>
      <td>X</td>
      <td>Smorgasbord</td>
    </tr>
    <tr>
      <td>java-prod</td>
      <td>Virtual</td>
      <td>Ubuntu 12.04 LTS (Precise Pangolin)</td>
      <td>X</td>
      <td>(TODO) Confluence, JIRA, MySQL, Apache</td>
    </tr>
    <tr>
      <td>java-test</td>
      <td>Virtual</td>
      <td>Ubuntu 12.04 LTS (Precise Pangolin)</td>
      <td>X</td>
      <td>(TODO) Confluence, JIRA, MySQL, Apache</td>
    </tr>
    <tr>
      <td>manage</td>
      <td>Virtual</td>
      <td>Ubuntu 12.04 LTS (Precise Pangolin)</td>
      <td>X</td>
      <td>Puppet Master, slapd -- firewalled to prevent remote access. For LDAP management instructions, login via SSH and run "sudo cat /root/ldap-notes.txt"</td>
    </tr>
    <tr>
      <td>svn</td>
      <td>Virtual</td>
      <td>Ubuntu 12.04 LTS (Precise Pangolin)</td>
      <td>X</td>
      <td>(TODO) Apache, SVN</td>
    </tr>
    <tr>
      <td>test-debian6</td>
      <td>Virtual</td>
      <td>Debian Squeeze</td>
      <td>X</td>
      <td>(TODO) Jenkins (Slave), Apache, MySQL, Drupal, Drush</td>
    </tr>
    <tr>
      <td>test-master</td>
      <td>Virtual</td>
      <td>Ubuntu 12.04 LTS (Precise Pangolin)</td>
      <td>X</td>
      <td>(TODO) Jenkins (Master)</td>
    </tr>
    <tr>
      <td>test-ubu1204-1</td>
      <td>Virtual</td>
      <td>Ubuntu 12.04 LTS (Precise Pangolin)</td>
      <td>X</td>
      <td>(TODO) Jenkins (Slave), Apache, MySQL, Drupal/Drush, CiviCRM</td>
    </tr>
    <tr>
      <td>test-ubu1210-1</td>
      <td>Virtual</td>
      <td>Ubuntu 12.10</td>
      <td>X</td>
      <td>(TODO) Jenkins (Slave), Apache, MySQL, Drupal/Drush, CiviCRM</td>
    </tr>
    <tr>
      <td>www-demo</td>
      <td>Virtual</td>
      <td>Ubuntu 12.04 LTS (Precise Pangolin)</td>
      <td>X</td>
      <td>(TODO) Apache, MySQL, Drupal, Joomla, WordPress, CiviCRM</td>
    </tr>
    <tr>
      <td>www-prod</td>
      <td>Virtual</td>
      <td>Ubuntu 12.04 LTS (Precise Pangolin)</td>
      <td>X</td>
      <td>(TODO) Apache, MySQL, Drupal/Drush, SMF, alert.civicrm.org</td>
    </tr>
    <tr>
      <td>www-training</td>
      <td>Virtual</td>
      <td>Ubuntu 12.04 LTS (Precise Pangolin)</td>
      <td>X</td>
      <td>(TODO) Apache, Mysql, Drupal/Drush, alert.dev.civicrm.org</td>
    </tr>
  </tbody>
</table>
