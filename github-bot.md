[botdylan](https://github.com/botdylan/botdylan) is a small framework for writing Github bots in NodeJS. 
[civicrm-botdylan](https://github.com/civicrm/civicrm-botdylan) extends botdylan to add a few features, eg:

 * Detect JIRA references in Github issues. Post bidirectional links between Github and JIRA.
 * Flag PR's to indicate their target branch.
 * Notify devs about [extremely complex functions](http://wiki.civicrm.org/confluence/display/CRM/Toxic+Code+Protocol).

The bot is deployed on the `botdylan.civicrm.org` host with user `co`.

If the system gets rebooted, you can restart it by saying:

```
sudo -u co -H bash
pm2 start /home/co/civicrm-botdylan/civicrm-botdylan.pm2.json
```

The `pm2` command also has a number of subcommands for restarting, checking statuses, checking logs, etc.
