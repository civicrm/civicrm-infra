# Setup a temporary gcloud worker (3rd generation)

The temporary gcloud worker is a [pre-emptible](https://cloud.google.com/preemptible-vms/) test node hosted on gcloud.

Pre-emptible nodes are cheaper and will automatically be destroyed within a
day.  They will execute some ephemeral jobs (like `CiviCRM-Core-Matrix`
and `Extension-SHA`), but they won't execute jobs where the intent is
to leave a test site for several days (like `CiviCRM-Core-PR`). Even so,
enabling a temporary node can help relieve backlog by increasing the
total available capacity.

## Restart an idle temp node

* Start the node; either:
    * CLI: `gcloud compute instances start bknix-181023`
    * Web UI
        * Navigate to https://console.cloud.google.com/compute/instances?project=nifty-buffer-107523
        * Start the idle node (e.g. `bknix-181023`)
        * Wait for it boot
* Update it to latest configuration
    * SSH into the new node
    * Run: `sudo -i bash -c '(cd /root/buildkit/ && git pull && ./nix/bin/update-ci-buildkit.sh)'`
* Enable it in Jenkins
    * Navigate to https://test.civicrm.org/computer/
    * Edit the corresponding node (e.g. `test-gc-181023`)
    * Update the IP and save
    * Bring the node online / launch the agent
