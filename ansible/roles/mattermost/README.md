Mattermost
==========

Mattermost configuration for https://chat.civicrm.org.

Includes:

* MySQL configuration (creates a "mattermost" database name and user account).
* Nginx vhost configuration.
* Mattermost plugins: mattermost-github-integration.
* Systemd unit files for mattermost and mattermost-github-integration.

Requires manual configuration:

* mattermost/config/config.json salts are not automatically generated (once the file is deployed, it is not updated by Ansible).
* mattermost-github-integration/config.py is not automatically deployed (has URLs of webhooks which are currently linked to bgm's account).

For more information on Mattermost installation, see:  
http://docs.mattermost.com/install/prod-debian.html
