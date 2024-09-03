# CiviCRM Infrastructure

This repo provides notes helpful for sysadmins working with the civicrm.org
infrastructure.

Issues: https://lab.civicrm.org/infrastructure/ops/issues/

## Related documentation

* CiviCRM docs
  * Update books from the documentation gitlab sub-groups and publishes them to https://docs.civicrm.org
  * Some documentation: https://lab.civicrm.org/infra/ops/-/wikis/docs

* CiviCRM statistics generation
  * Fetches data from various sources
  * Git repo: https://lab.civicrm.org/infra/stats-collection

* CiviCRM pingback collection
  * Handles pingbacks from CiviCRM instances (check-version job) and communicate "your CRM needs an upgrade"
  * Git repo: https://lab.civicrm.org/infra/pingback.git

* CiviCRM in-app messages
  * Git repo: https://lab.civicrm.org/infra/community-messages
  * Relies on a Google Spreadsheet which has the filters/messages to be displayed in-app

* CiviCRM website
  * Platform: we use the Coop Symbiotic platform for Drupal 9/10 (the git repo
    is not public, but it's nothing fancy).
  * Site (theme and custom modules, extensions): https://lab.civicrm.org/marketing/civicrm-website/

* CiviCRM Spark
  * Platform: https://lab.civicrm.org/core-team/civicrm-spark/mycivi
  * Has a Gitlab CI/CD pipeline to run CiviCRM code upgrades
  * Servers: spark-1 (North America) and spark-2 (Europe), runs Aegir using Symbiotic's tooling
  * When people signup on civicrm.com, a custom extension called "symbiocivicrm" has civi hooks to trigger the creation of the site
  * More documentation: https://lab.civicrm.org/core-team/civicrm-spark/mycivi/-/wikis/automatic-site-create

* Botdylan: the Github bot that responds to PRs and updates issues on Gitlab:
  * Git repo: https://github.com/civicrm/probot-civicrm
  * Requires a Gitlab token that must be updated on a yearly basis
  * Secrets/tokens: see the botdylan.civicrm.org VM, in the botdylan systemd service

* civicrm.org/Gitlab integration
  * When a new extension (node) is added to civicrm.org, it creates a new Gitlab repo
  * Requires a Gitlab token that must be updated on a yearly basis
  * Documentation at: https://lab.civicrm.org/marketing/civicrm-website/-/blob/d8/modules/custom/extdir/README.md

* Most servers are configured using Ansible, although we stopped maintaining
  forks of the roles in this repo, and mostly use the roles by Coop Symbiotic
  (https://github.com/coopsymbiotic/coopsymbiotic-ansible/). Servers are documented
  either in the `hosts.md` file or in the `ansible/hosts` file.
