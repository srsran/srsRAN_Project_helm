## 0.1.0 (September 29, 2023)
### Added
- Initial release of the srsRAN Project Helm chart.
  - This chart facilitates the deployment of srsRAN Project's CU/DU as a unified, single-binary solution for ORAN.

## 1.0.0 (Dezember 20, 2023)
### Log
- All config options are configurable over values.yaml or cli.
- Moved config over to values.yaml
- Added autostart metrics

## 1.1.0 (November 11, 2024)
### Log
- srsRAN: Refactor configmap template
- srsRAN: Update example config to srsRAN Project 2024.10
- linuxptp: Upgrade container to Ubuntu 24.04 and select linuxptp v4.3
- grafana: Add initial version of SRS Grafana Helm Chart
- srsRAN: Upgrade DPDK to 23.11
- srsRAN: Add initial version of RU Emulator
- srsRAN: Add option to store log files on node
- srsRAN: Fix DNS issues with dnsPolicy
- images: Move some Dockerfiles to the srsRAN Project Github repository
- Open5gs: Update example values.yaml file
- linuxptp: Extend chart capabilities by TS2PHC
- linuxptp: Set priorityClassName to system-node-critical
