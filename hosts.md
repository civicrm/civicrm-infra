Virtual Servers
===============

<table>
  <thead>
    <tr>
      <th>Host</th>
      <th>Domain</th>
      <th>OS</th>
      <th>IPv4</th>
      <th>IPv6</th>
      <th>Resources</th>
      <th>Comments</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>chat</td>
      <td>civicrm.org</td>
      <td>Debian 13 Trixie</td>
      <td>51.77.81.202</td>
      <td>2001:41d0:725:7100:300::</td>
      <th>cores=4 ram=4gb root=50gb (updated: 2025-07-24)</th>
      <td>Mattermost, Nginx, MariaDB</td>
    </tr>
    <tr>
      <td>cxnapp-2</td>
      <td>Google Cloud</td>
      <td>Ubuntu 16.04 LTS (Xenial)</td>
      <td>146.148.42.42</td>
      <td></td>
      <th>cores=1 ram=1gb root=10gb (updated: 2017-04-24)</th>
      <td><tt>mycivi.org</tt> and <tt>dev.mycivi.org</tt> (<a href="https://github.com/civicrm/cxnapp">cxnapp</a>, configured to run <tt>org.civicrm.profile</tt> in <tt>/srv/buildkit</tt>)</td>
    </tr>
    <tr>
      <td>lab</td>
      <td>civicrm.org (OSUOSL)</td>
      <td>Ubuntu 20.04 LTS (Focal)</td>
      <td>140.211.167.160</td>
      <td>2605:bc80:3010:102:0:3:4:0</td>
      <th>cores=3 ram=4gb root=50gb (updated: 2017-04-17)</th>
      <td>lab.civicrm.org (gitlab-omnibus)</td>
    </tr>
    <tr>
      <td>latest</td>
      <td>civicrm.osuosl.org</td>
      <td>Ubuntu 16.04 LTS (Xenial)</td>
      <td>140.211.167.189</td>
      <td>2605:bc80:3010:102:0:3:5::0</td>
      <th>cores=2 ram=2gb hdd=39gb (updated: 2015-09-25)</th>
      <td></td>
    </tr>
    <tr>
      <td>manage</td>
      <td>civicrm.osuosl.org</td>
      <td>Ubuntu 18.04 LTS (Xenial)</td>
      <td>140.211.167.144</td>
      <td></td>
      <th>cores=2 ram=1gb root=15gb (updated: 2014-10-27)</th>
      <td>slapd, phpldapadmin -- all firewalled to prevent remote access. For LDAP management instructions, login via SSH and run "sudo cat /root/ldap-notes.txt", enable apache and disable when done</td>
    </tr>
    <tr>
      <td>test</td>
      <td>civicrm.org</td>
      <td>Debian 12 (Bookworm)</td>
      <td>35.226.128.213</td>
      <td></td>
      <th>cores=1 ram=3.5gb root=50gb (updated: 2024-11-01)</th>
      <td>Jenkins (Master), Nginx (for HTTPS), PHP (for Duderino). Hosted on Google Cloud.</td>
    </tr>
    <tr>
      <td>www-cxn-2</td>
      <td>civicrm.osuosl.org</td>
      <td>Ubuntu 16.04 LTS (Xenial)</td>
      <td>140.211.167.175</td>
      <td></td>
      <th>cores=2 ram=1.5gb root=10gb (updated: 2015-09-20)</th>
      <td>Apache, MySQL, PHP56</td>
    </tr>
    <tr>
      <td>www-demo</td>
      <td>paella.osuosl.org</td>
      <td>Debian 12 (Bookworm)</td>
      <td>192.95.2.129</td>
      <td>2607:5300:203:6713:600::</td>
      <th>cores=2 ram=4gb root=? (updated: 2024-10-31)</th>
      <td>Apache, MySQL, Drupal, WordPress, CiviCRM</td>
    </tr>
    <tr>
      <td>www-prod</td>
      <td>civicrm.osuosl.org</td>
      <td>Ubuntu 18.04 LTS (Bionic)</td>
      <td>140.211.167.152</td>
      <td>2605:bc80:3010:102:0:3:1:0</td>
      <th>cores=2 ram=6gb root=25gb (updated: 2014-10-27)</th>
      <td>Nginx, MySQL, PHP, SMF/forum.civicrm.org, alert.civicrm.org, docs.civicrm.org</td>
    </tr>
    <tr>
      <td>backup-1</td>
      <td>Google Cloud</td>
      <td>Ubuntu 16.04 LTS (Xenial)</td>
      <td>107.178.223.170</td>
      <td></td>
      <th>cores=1 ram=1.7gb root=25gb (updated: 2015-10-10)</th>
      <td>Backups</td>
    </tr>
    <tr>
      <td>test-1</td>
      <td>OVH</td>
      <td>Debian 12 (Bookworm)</td>
      <td>192.95.2.130</td>
      <td></td>
      <th>cores=6 ram=20gb root=150gb (updated: 2018-09-13)</th>
      <td>Tests</td>
    </tr>
    <tr>
      <td>test-2</td>
      <td>OSUOSL</td>
      <td>Debian 12 (Bookworm)</td>
      <td>140.211.167.149</td>
      <td></td>
      <th>cores=4 ram=8gb root=50gb</th>
      <td>Tests</td>
    </tr>
    <tr>
      <td>botdylan</td>
      <td>OVH</td>
      <td>Ubuntu 16.04 LTS (Xenial Xerus)</td>
      <td>192.95.2.132</td>
      <td></td>
      <th>cores=2 ram=2gb root=25gb (updated: 2015-04-22)</th>
      <td>Tests</td>
    </tr>
  </tbody>
</table>

Physical Servers
================

| Host                | OS                 | Location          | IPv4              | IPv6                 | Resources         | Comments                                                                   |
| ------------------- | ------------------ | ----------------- | ----------------  | -------------------- | ----------------- | -------------------------------------------------------------------------- |
| test-3.civicrm.org  | Debian 11 bullseye | OVH BHS           | 15.235.112.148    | n/a                  | cores=8/16 (AMD 5800X) ram=128gb ssd=2x1tb (updated: 2023-04-17) | Previously barbecue |
| sushi.civicrm.org   | Ubuntu 18.04       | OSUOSL            | 140.211.166.28    | n/a                  | cores=2(Pentium 1403v2) ram=32gb hdd=3x600gb(10k,2.5) | Backup server. 1+3yr wty (2015-2019?) |
| paella.civicrm.org  | Debian 10 buster   | OVH BHS           | 51.161.13.19      | 2607:5300:203:6713:: | cores=12 (A2-E2136) ram=64gb ssd=2x500gb (updated: 2020-01-30) | Will be replaced by bagel.c.o |
| bagel.civicrm.org   | Debian 12 bookworm | OVH BHS           | 148.113.217.125   | 2607:5300:21a:7d00:: | cores=8/16 Advanced-2 AMD EPYC 4344P 8c/16t - 3.8 GHz/5.3 GHz, 128 GB RAM, 2x1 TB NVMe disks | Will replace paella.c.o |
| test-4.us.to        | Ubuntu 22.04 Jammy | Garage            | Dynamic           | n/a                  | cores=6c/12t (i5-12500t) ram=64gb ssd=1x250gb + 1x1tb (updated: 2024-12-03) | "install-runner.sh". Jenkins worker. Behind NAT firewall. Use alt ssh port 55 or Nebula (test-4.ab31.civi.io). vPro AMT via VPN. |
| test-5.port0.org    | Ubuntu 22.04 Jammy | Garage            | Dynamic           | n/a                  | cores=6c+8c/20t (i5-13600t) ram=64gb ssd=1x1tb (updated: 2024-12-03) | "install-runner.sh". Jenkins worker. Behind NAT firewall. Use alt ssh port 56 or Nebula (test-5.ab31.civi.io). |

Old Ganeti hosts at OSUOSL:

<table>
  <thead>
    <tr>
      <th>Host</th>
      <th>Domain</th>
      <th>OS</th>
      <th>IP</th>
      <th>Resources</th>
      <th>Comments</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>civicrm1</td>
      <td></td>
      <td>?? (Ganeti)</td>
      <td></td>
      <td>
<pre>
CPU: 2 x Intel Xeon E5-2407, 2.2GHz (4-Core, 10MB Cache, 80W) 32nm
RAM: 48GB (6 x 8GB DDR3-1600 ECC Registered 2R DIMMs) Operating at 1600 MT/s Max
NIC: Dual Intel 82574L Gigabit Ethernet Controllers - Integrated
Management: Integrated IPMI 2.0 & KVM over LAN
Hot-Swap Drive - 1: 500GB Western Digital VelociRaptor (6Gb/s, 10K RPM, 64MB Cache) 3.5" SATA 
Hot-Swap Drive - 2: 500GB Western Digital VelociRaptor (6Gb/s, 10K RPM, 64MB Cache) 3.5" SATA 
Hot-Swap Drive - 3: 500GB Western Digital VelociRaptor (6Gb/s, 10K RPM, 64MB Cache) 3.5" SATA 
Hot-Swap Drive - 4: 180GB Intel 520 Series MLC (6Gb/s) 2.5" SATA SSD
Optical Drive: No Drive
Power Supply: Redundant 400W Power Supply with PMBus and I2C
Selected
Warranty: Std 3-Yr Warranty + 3-Yr Expanded Warranty, Next Business Day On Site - Spare Parts Req
</pre>
      </td>
    </tr>
    <tr>
      <td>civicrm2</td>
      <td></td>
      <td>?? (Ganeti)</td>
      <td></td>
      <td>
<pre>
CPU: 2 x Intel Xeon E5-2407, 2.2GHz (4-Core, 10MB Cache, 80W) 32nm
RAM: 48GB (6 x 8GB DDR3-1600 ECC Registered 2R DIMMs) Operating at 1600 MT/s Max
NIC: Dual Intel 82574L Gigabit Ethernet Controllers - Integrated
Management: Integrated IPMI 2.0 & KVM over LAN
Hot-Swap Drive - 1: 500GB Western Digital VelociRaptor (6Gb/s, 10K RPM, 64MB Cache) 3.5" SATA 
Hot-Swap Drive - 2: 500GB Western Digital VelociRaptor (6Gb/s, 10K RPM, 64MB Cache) 3.5" SATA 
Hot-Swap Drive - 3: 500GB Western Digital VelociRaptor (6Gb/s, 10K RPM, 64MB Cache) 3.5" SATA 
Hot-Swap Drive - 4: 180GB Intel 520 Series MLC (6Gb/s) 2.5" SATA SSD
Optical Drive: No Drive
Power Supply: Redundant 400W Power Supply with PMBus and I2C
Warranty: Std 3-Yr Warranty + 3-Yr Expanded Warranty, Next Business Day On Site - Spare Parts Req
</pre>
      </td>
    </tr>
  </tbody>
</table>

IPv6 allocation at OSUOSL
=========================

For civicrm1 and civicrm2 :

```
2605:bc80:3010:102:0:3::/96

2605:bc80:3010:102:0:3:0000:0000-
2605:bc80:3010:102:0:3:ffff:ffff

Meaning that we can assign a /112 per VM, providing 0xffff (65535) IPs per VM:

2605:bc80:3010:102:0:3::/112
2605:bc80:3010:102:0:3:1::/112 - www-prod.civicrm.osuosl.org
2605:bc80:3010:102:0:3:2::/112 - java-prod.civicrm.osuosl.org
2605:bc80:3010:102:0:3:3::/112 - chat.civicrm.osuosl.org
2605:bc80:3010:102:0:3:4::/112 - lab.civicrm.org
2605:bc80:3010:102:0:3:5::/112 - latest.civicrm.org
[...]
2605:bc80:3010:0102:0000:0003:ffff::/112
```

The reverse-DNS is managed by OSUOSL. To change, we need to open a ticket with `support@`.
