# Setup a temporary gcloud worker (4th generation, runner-style)

The temporary gcloud worker is a [pre-emptible](https://cloud.google.com/preemptible-vms/) test node hosted on gcloud.

Pre-emptible nodes are cheaper and will automatically be destroyed within a
day.  They will execute some ephemeral jobs (like `CiviCRM-Core-Matrix`
and `Extension-SHA`), but they won't execute jobs where the intent is
to leave a test site for several days (like `CiviCRM-Core-PR`). Even so,
enabling a temporary node can help relieve backlog by increasing the
total available capacity.

## Add an ephemeral node

* Navigate to https://test.civicrm.org/computer/
* In the middle of the node list, there is an option "Provision via nifty-buffer-NNNNN"

## Update the baseline/template

Ephemeral nodes have an auto-update procedure -- when booting, they will download the latest `civicrm-buildkit.git`.  Changes are usually
small - so most updates are usually quick.

However, every few months, you may have a sigificiant update to `civicrm-buildkit.git` (_e.g.  using a new version of `nixpkgs` or `php`
requires downloading or compiling a large number of packages_).  These updates would exaggerate boot-time and bandwidth-usage.  After a
significant change, one should make a new baseline/snapshot (with changes baked-in).

* Update the VM "Instance" (`bknix-run`)
    * __Note__: In Gcloud, the "Instance" is a specific virtual-machine. We have an idle VM that is handy for preparing updates.
    * Start the base VM
        * __CLI__: `gcloud compute instances start bknix-runner-base`
        * __Web UI__: Navigate to https://console.cloud.google.com/compute/instances?project=nifty-buffer-107523
    * Update the base VM
        * __CLI__:
            * Connect via SSH
            * There is a [startup script](https://cloud.google.com/compute/docs/instances/startup-scripts/linux) that auto-updates.
                * You can check on its progress (`sudo journalctl -u google-startup-scripts.service`)
            * You can do a similar update manually:
                ```bash
                sudo -i bash -c '(cd /opt/buildkit/ && git pull && ./nix/bin/install-runner.sh)'
                ```
            * If you want to test things out, you might create some example builds (and then destroy them).
                ```bash
                sudo -iu dispatcher run-bknix-job --mock min shell
                civibuild create delme-1-1 --type drupal-clean
                civibuild destroy delme-1-1
                ```
            * Tidy up
                ```bash
                sudo -i bash -c '(cd /opt/buildkit/ && ./nix/bin/tidy-gcloud.sh)'
                ```
    * Shutdown the base VM
        * __CLI__: `gcloud compute instances stop bknix-runner-base`
        * __Web UI__: Navigate to https://console.cloud.google.com/compute/instances?project=nifty-buffer-107523
* Create/update the "Image" (`bknix-run-img-YYYY-MM-DD`)
    * __Note__: In Gcloud, the "Image" is a large binary blob. We will create a new/updated image (`bknix-run-img-YYYY-MM-DD`).
    * __CLI__:
        ```bash
        gcloud compute images create --project=nifty-buffer-107523 \
          --source-disk=bknix-runner-base --source-disk-zone=us-central1-f \
          --storage-location=us --family=bknix-run-img bknix-run-img-YYYY-MM-DD
        ```
    * __Web UI__: https://console.cloud.google.com/compute/images?tab=images&project=nifty-buffer-107523
* Create/update the "Instance Template" (`bknix-run-YYYY-MM-DD`)
    * __Note__: In Gcloud, the "Instance Template" describes configuration options for future VMs (eg RAM/CPU/disk/networking). We will create a new/updated template (`bknix-n2s4-preempt-NN`).
    * __Web UI__: Navigate to https://console.cloud.google.com/compute/instanceTemplates/list?project=nifty-buffer-107523
        * Find and open the most recent template (eg `bknix-run-YYYY-MM-DD`)
        * Click "Create Similar"
        * Keep most settings, but...
        * Change the boot disk image to the "Custom" image named `bknix-run-img-YYYY-MM-DD` (60gb limit)
* Use the updated template
    * __Web UI__: Navigate to https://test.civicrm.org/configureClouds/
       * Find the "Machinge configuration" for bknix.
       * Update the "Template to use" (`bknix-run-YYYY-MM-DD`)
