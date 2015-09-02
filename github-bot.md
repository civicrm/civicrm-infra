[botdylan](https://github.com/botdylan/botdylan) is a small framework for writing Github bots in NodeJS. 
[civicrm-botdylan](https://github.com/civicrm/civicrm-botdylan) extends botdylan to add a few features, eg:

 * Detect JIRA references in Github issues. Post bidirectional links between Github and JIRA.
 * Flag PR's to indicate their target branch.
 * Notify devs about [extremely complex functions](http://wiki.civicrm.org/confluence/display/CRM/Toxic+Code+Protocol).

The bot is deployed on the `svn` host.

It depends on a newer version of libc, so it runs inside a docker container.

To check on it, use `screen -ls`, note the relevant terminal, and then `screen -r [the-screen-id]`

If the system gets rebooted, you can restart it by saying:

```
$ sudo bash
$ screen
$ su - co
$ cd ~/civicrm-botdylan
$ bash docker-run.sh
```
