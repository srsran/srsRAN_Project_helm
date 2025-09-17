# Changelog

## 2.2.0 (September 18, 2025)
### Added
- Add service for Telegraf metrics collection
- Refactor configMap naming to support multiple instances deployment
### Changed
- Refactor entrypoint script to update HAL section
- Update entrypoint to return exit code of gNB process
- Update PID of the gNB process before calling kill
- Improve hostnetwork adaptation for gNB Pod
- Fix symlink creation and path handling in entrypoint
- Fix default value of PRESERVE_OLD_LOGS
- Create symlink to current log folder
- Save stdout in separate file

## 2.1.0 (April 16, 2025)
### Changed
- Forward SIGINT in the gNB entrypoint script to child processes.
- Forward SIGTERM in case the pod is killed externally.
- Preserve logs by creating a folder instead of appending a timestamp to old files.
- Fix several env‑var inclusion bugs in the Deployment template.
- Add functionality to avoid overwriting old logs on restart.
- Add a license header to the gNB entrypoint script.
- Provide an example `values.yaml` for LB + SR‑IOV plugin setups.
- Refactor and expand comments in `values.yaml`.
- Document needed `securityContext` when LB is enabled.
- Add a note about `hostNetwork` in LB‑enabled scenarios.
- Introduce an SR‑IOV-aware entrypoint script for gNB pods.
- Expose a LoadBalancer for N2, N3 and O1 interfaces.
- Fix indentation and formatting in `deployment.yaml`.
- Update and standardize the `README.md` for the chart.
- Switch the gNB command syntax to the new format.
- Retry gNB startup if it shuts down successfully.
- Fix the `postStart` hook for the O1 Adapter container.
- Add helpers to allow SHA‑256 digests as well as plain tags.
- Extend the example `o1_values.yaml` with a HAL section.
- Fix Netconf volume mounts in the StatefulSet.
- Correct paths for O1 config in the adapter.
- Correct the path of the `gnb.yaml` config template.
- Add an example `values-o1.yaml` for full O1 setup.

## 1.1.0 (November 04, 2024)
### Changed
- Update default chart config to match the 24.10 upstream release.
- Write the ConfigMap directly from `values.yaml` (no intermediate staging file).
- Append a suffix to all log and pcap filenames.
- Update the Docker image name in the Deployment.
- Fix issues in `configmap.yaml` and strip leftover comments.
- Allow toggling `hostNetwork` via `values.yaml`.
- Upgrade DPDK to 23.11
- Add initial version of RU Emulator
- Add option to store log files on node
- Fix DNS issues with dnsPolicy

## 1.0.0 (December 20, 2023)
### Added
- Deploys the srsRAN gNB with configurable parameters
- Moved config over to values.yaml
- Added autostart metrics

## 0.1.0 (September 29, 2023)
### Added
- Initial release of the srsRAN Project Helm chart

