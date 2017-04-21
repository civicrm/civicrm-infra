# civicrm.org: Distribution infrastructure

The distribution infrastructure provides for packaging, storing, and
transferring builds of CiviCRM.

## Downloads

The host `download.civicrm.org` supports URLs like:

 * `https://download.civicrm.org/civicrm-4.7.10-drupal.tar.gz`
 * `https://download.civicrm.org/latest`
 * `https://download.civicrm.org/latest/civicrm-RC-wordpress.zip`
 * `https://download.civicrm.org/civix/civix.phar`

This host provides *redirects* to Google Cloud Storage, which provides the
long-term storage and data-transfer services.

The host is implemented with
[civicrm-dist-manager](https://github.com/civicrm/civicrm-dist-manager). 
See the README for more details about supported URLs/routes.  To implement
new listings or URL patterns, update `civicrm-dist-manager`.

> For transitional purposes, the experimental domain `upgrade.civicrm.org` is
> an alias for `download.civicrm.org`.  However, `upgrade.civicrm.org` is
> deprecated.

## Autobuild

The autobuild process monitors CiviCRM git repositories; whenever there's a
change, it prepares a new set of "NIGHTLY" or "RC" tarballs and uploads to
gcloud.

These Jenkins jobs drive the process.  If you need to trigger a manual build
or inspect logs for errors/failures, then go to `test.civicrm.org`.

 * https://test.civicrm.org/view/Publish/job/CiviCRM-Publish/ (_Build new tarballs. Upload them to `gs://civicrm-build`._)
 * https://test.civicrm.org/view/Publish/job/CiviCRM-Publish-Watch-Core/ (_Monitor `civicrm-core.git` for changes; trigger `CiviCRM-Publish` w/proper branch._)
 * https://test.civicrm.org/view/Publish/job/CiviCRM-Publish-Watch-Packages/ (_Monitor `civicrm-packages.git` for changes; trigger `CiviCRM-Publish` w/proper branch._) (_TODO_)
 * https://test.civicrm.org/view/Publish/job/CiviCRM-Publish-Watch-Backdrop/ (_Monitor `civicrm-backdrop.git` for changes; trigger `CiviCRM-Publish` w/proper branch._) (_TODO_)
 * https://test.civicrm.org/view/Publish/job/CiviCRM-Publish-Watch-Drupal/ (_Monitor `civicrm-drupal.git` for changes; trigger `CiviCRM-Publish` w/proper branch._) (_TODO_)
 * https://test.civicrm.org/view/Publish/job/CiviCRM-Publish-Watch-Joomla/ (_Monitor `civicrm-joomla.git` for changes; trigger `CiviCRM-Publish` w/proper branch._) (_TODO_)
 * https://test.civicrm.org/view/Publish/job/CiviCRM-Publish-Watch-WordPress/ (_Monitor `civicrm-wordpress.git` for changes; trigger `CiviCRM-Publish` w/proper branch._) (_TODO_)

> At time of writing, this iteration of the autobuild system is new, and I'd
> like to see it running a bit longer before we reproduce the configuration on
> each repo.

These jobs are not strongly tied to any particular host or data.  The main
requirement is that `CiviCRM-Publish` run on a system with
[buildkit](http://github.com/civicrm/civicrm-buildkit).  The job should be
compatible with most PHP 5.x test-nodes.

It's quite likely that -- from time to time -- there will be multiple PRs
merged within a few minutes of each other.  To avoid a stampede and reduce
duplicate builds, the `CiviCRM-Publish` job will wait a few minutes before
starting a new build.  (This is a Jenkins "quiet period".)

Autobuild files uploaded to `gs://civicrm-build` will expire within 14 days. 
(See `gsutil lifecycle`.)
