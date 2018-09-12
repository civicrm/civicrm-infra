# Jenkins job snapshots

This folder contains periodic snapshots of key job configurations.  It is
*not* a backup and is not structurally up-to-date.  Rather, it's a
development aid to compensate for the lack of decent version-control on the
configuration.

Usage:

* If you're doing some non-trivial changes to the job's bash script, then...
* View the current job's configuration in the web UI.
* Copy the current bash script into this file.
* (Optionally) Note the differences. Commit.
* Edit the file to taste. 
* Paste it back into Jenkins.
* ... try it out in Jenkins...
* If it works, then commit.
