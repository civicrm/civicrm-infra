MySQL backup
============

Includes:

* Installation of https://cytopia.github.io/mysqldump-secure/
  * Included/patched in this repo, because by default it makes it hard to use /etc/mysql/debian.cnf
  * Also patched to allow overwriting existing files, to avoid rdiff backup growth, and avoid need for tmpreaper.
* Configuration inspired from https://github.com/infOpen/ansible-role-mysql-backup/

Overview (assuming defaults):

* MySQL dumps are stored in: /var/backups/mysql/
* The cron runs daily, around 20:30 because rdiff-backup runs at 21:00 (UTC)
* Runs using the Debian sys-maint (/etc/mysql/debian.cnf)
* Logs in: /var/backups/mysqldump-secure.monitoring.log (monitored by Icinga)
