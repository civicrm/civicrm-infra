Hosts
=====

<table>
  <thead>
    <tr>
      <th>Host</th>
      <th>Domain</th>
      <th>Type</h>
      <th>OS</th>
      <th>IP</th>
      <th>Comments</th>
    </tr>
  </thead>
  <tbody>
      <tr>
      <td>biryani</td>
      <td>osuosl.org</td>
      <td>Physical</td>
      <td>Ubuntu 10.4 LTS (Lucid Lynx)</td>
      <td>140.211.166.57</td>
      <td>Smorgasbord</td>
    </tr>
    <tr>
      <td>sushi</td>
      <td>osuosl.org</td>
      <td>Physical</td>
      <td>Ubuntu 8.04 LTS (Hardy Heron)</td>
      <td>140.211.166.55</td>
      <td>Smorgasbord</td>
    </tr>
    <tr>
      <td>java-prod</td>
      <td>civicrm.osuosl.org</td>
      <td>Virtual</td>
      <td>Ubuntu 12.04 LTS (Precise Pangolin)</td>
      <td>140.211.167.141</td>
      <td>(TODO) Confluence, JIRA, MySQL, Apache</td>
    </tr>
    <tr>
      <td>java-test</td>
      <td>civicrm.osuosl.org</td>
      <td>Virtual</td>
      <td>Ubuntu 12.04 LTS (Precise Pangolin)</td>
      <td>40.211.167.143</td>
      <td>(TODO) Confluence, JIRA, MySQL, Apache</td>
    </tr>
    <tr>
      <td>manage</td>
      <td>civicrm.osuosl.org</td>
      <td>Virtual</td>
      <td>Ubuntu 12.04 LTS (Precise Pangolin)</td>
      <td>140.211.167.144</td>
      <td>Puppet Master, slapd, phpldapadmin -- all firewalled to prevent remote access. For LDAP management instructions, login via SSH and run "sudo cat /root/ldap-notes.txt"</td>
    </tr>
    <tr>
      <td>svn</td>
      <td>civicrm.osuosl.org</td>
      <td>Virtual</td>
      <td>Ubuntu 12.04 LTS (Precise Pangolin)</td>
      <td>140.211.167.145</td>
      <td>(TODO) Apache, SVN</td>
    </tr>
    <tr>
      <td>test-debian6-1</td>
      <td>civicrm.osuosl.org</td>
      <td>Virtual</td>
      <td>Debian Squeeze</td>
      <td>140.211.167.146</td>
      <td>(TODO) Jenkins (Slave), Apache, MySQL, Drupal, Drush</td>
    </tr>
    <tr>
      <td>test-master</td>
      <td>civicrm.osuosl.org</td>
      <td>Virtual</td>
      <td>Ubuntu 12.04 LTS (Precise Pangolin)</td>
      <td>140.211.167.147</td>
      <td>(TODO) Jenkins (Master)</td>
    </tr>
    <tr>
      <td>test-ubu1204-1</td>
      <td>civicrm.osuosl.org</td>
      <td>Virtual</td>
      <td>Ubuntu 12.04 LTS (Precise Pangolin)</td>
      <td>140.211.167.149</td>
      <td>(TODO) Jenkins (Slave), Apache, MySQL, Drupal/Drush, CiviCRM</td>
    </tr>
    <tr>
      <td>test-ubu1210-1</td>
      <td>civicrm.osuosl.org</td>
      <td>Virtual</td>
      <td>Ubuntu 12.10</td>
      <td>140.211.167.150</td>
      <td>(TODO) Jenkins (Slave), Apache, MySQL, Drupal/Drush, CiviCRM</td>
    </tr>
    <tr>
      <td>www-demo</td>
      <td>civicrm.osuosl.org</td>
      <td>Virtual</td>
      <td>Ubuntu 12.04 LTS (Precise Pangolin)</td>
      <td>140.211.167.151</td>
      <td>(TODO) Apache, MySQL, Drupal, Joomla, WordPress, CiviCRM</td>
    </tr>
    <tr>
      <td>www-prod</td>
      <td>civicrm.osuosl.org</td>
      <td>Virtual</td>
      <td>Ubuntu 12.04 LTS (Precise Pangolin)</td>
      <td>140.211.167.152</td>
      <td>(TODO) Apache, MySQL, Drupal/Drush, SMF, alert.civicrm.org</td>
    </tr>
    <tr>
      <td>www-training</td>
      <td>civicrm.osuosl.org</td>
      <td>Virtual</td>
      <td>Ubuntu 12.04 LTS (Precise Pangolin)</td>
      <td>140.211.167.153</td>
      <td>(TODO) Apache, Mysql, Drupal/Drush, alert.dev.civicrm.org</td>
    </tr>
  </tbody>
</table>
