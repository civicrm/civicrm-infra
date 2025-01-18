# Continuous integration

Continuous integration (CI) is the practice of automating build, testing, and release during development.  [Jenkins](https://jenkins-ci.org/) is a
job-management system focused on CI – and provides a large library of plugins for source-code management, quality-assurance, etc.

## Deployment architecture

* https://test.civicrm.org is the Jenkins "master" node.  It runs contiuously, providing the web UI for managing and browsing jobs.
* https://test.civicrm.org/duderino/ is a customized interface for initiating and tracking large matrix jobs.
* All the real work is done by sending jobs to "worker" nodes. Worker-nodes deal with different workloads and run on different classes of hardware.

| Node  | Workload | Machine Class |
| -- | -- | -- |
| `test-1` | Operates PR demo sites. Each site tends to live for a few days. | Public server, dedicated hardware (proper data center) |
| `test-2` | Build final releases and handles other glue. (It should not execute new/unapproved/unreviewed code.) | Public server, dedicated virtual machine (proper data center) |
| `test-3` | Execute test suites (PRs and scheduled). Based on `civicrm-buildkit:nix/bin/install-runner.sh`. | Public server, dedicated hardware (proper data center) |
| `test-4` | Execute test suites (PRs and scheduled). Based on `civicrm-buildkit:nix/bin/install-runner.sh`. | Firewalled desktop |
| `test-5` | Execute test suites (PRs and scheduled). Based on `civicrm-buildkit:nix/bin/install-runner.sh`. | Firewalled desktop |
| `bknix-run-XXXX` | Execute test suites (PRs and scheduled). Based on `civicrm-buildkit:nix/bin/install-runner.sh`. | Public cloud, spot VM |

* As you might expect, most nodes are dedicated toward running test-suites. (The test-suites are large.) Some notes about these:
    * The key criteria for these machines (*roughly ordered, most-important to least-important*):
         * Single-threaded CPU performance is the major driver of runtime in Civi's PHP/MySQL/PHPUnit architecture.
         * Running many tests back-to-back on the same hardware means that each node keeps hydrated caches. This reduces setup time.
         * Price is always important.
         * Availability is well-and-good, but individual nodes don't need 99.9% uptime. There are multiple nodes and a "Retry" feature.
         * Aggregate multi-core performance is well-and-good, but a large number of slow-cores won't help with our frameworks.
    * `test-{3,4,5}` represent the *base capacity*. They operate continuously. Most jobs should execute on these nodes.
    * `test-3` is the safest part of the base-capacity. (It's got decent hardware and runs in a professional data-center.)
    * In recent years, firewalled desktops have provided best price/performance and sufficient availability. But we shouldn't rely on them exclusively. In principle, there are multiple single-failure-points and no 24x7 hardware-team. We don't want one power-outage to kill all testing.
    * With `bknix-run-XXXX`, we can use Google Cloud to scale-up/scale-down.
        * Spot VMs can be useful for (a) dealing with spikes in demand (*dev-sprints*) and (b) dealing with outages/maintenance in the base-capacity.
        * Pricing for "spot VMs" is... OK. (Not great, not terrible.)
        * Gcloud may kill spot VMs at random times. This is recoverable (*affected developers can re-run failed tests*). But it will happen several times per day, and it's a bit annoying to do manual-retries. So we shouldn't rely on "spot VMs" for base-capacity. (*That could change if the kill/retry mechanics get better.*)

## Suggestions

* If we have ample base-capacity and don't need ephemeral nodes:
    * Go to https://test.civicrm.org/configureClouds/. Update the cloud configuration.
    * Drop the instance-limit to 1.
    * Find the general options for `bknix-run`. Update the "Labels". Ensure they are "disabled" (i.e. `disabled-bknix-tmp disabled-bknix-tmp-edge`). This will prevent Jenkins from spawning more nodes.
* If the base-capacity isn't sufficient (*spikes in demand or maintenance/outages*) and we need more ephemeral nodes:
    * Go to https://test.civicrm.org/configureClouds/. Update the cloud configuration.
    * Check the instance-limit. Consider raising it to 2-4 nodes. (Note that each node can handle a couple parallel tests.)
    * Find the general options for `bknix-run`. Update the node "Labels". Ensure thare NOT "disabled" (i.e. `bknix-tmp`, not `disabled-bknix-tmp`).
* If `test-4` or `test-5` become non-responsive:
    * Find an Android or iOS device.
    * Install and open the "Tapo" app from "TP-Link".
    * Login with a "TP-Link ID". (Note: the first time you use this, you'll need to create an account. Then go on Mattermost and ask for an invitation to see the devices.)
    * In the "Test Servers: Office", there should be nodes for `test-4` and `test-5` with options to power-off, power-on, and measure power-usage.
* If `test-4` becomes non-responsive:
    * (*It's possible to connect to a VPN and use Mesh Commander to open a console. Cost-benefit of documenting this isn't great -- need multiple credentials+tools, but only get access to one node, and it's very rare to need it. If in doubt, it's probably easier to re-enable gcloud nodes until someone gets physical hands on it.*)

## Related documents

* [Jenkins Website](http://jenkins-ci.org/)
* ~~[Setup master node](continuous-integration/master.md)~~
* ~~[Setup worker node (1st generation)](continuous-integration/worker-gen-1.md)~~
* ~~[Setup worker node (3rd generation)](continuous-integration/worker-gen-3.md)~~
* [Setup worker nodes (4th gen, Google Cloud)](continuous-integration/worker-gen-4r-gcloud.md)
