# IRC bots

## CiviBot

CiviBot is a logging bot for the #civicrm IRC channel on Freenode.
The bot runs from biryani since 2015-09-01, before that it ran on sushi.

Configurations:

* To restart the bot, use the init script (/etc/init.d/eggdrop)

* Part of the configurations are handled by Puppet, using the civicrmorg::eggdrop class.
  This includes the init script, eggdrop package, eggdrop user and group.
  The rest is managed manually (vhost, stuff in /var/www/irc.civicrm.org, contents of /home/eggdrop/).
