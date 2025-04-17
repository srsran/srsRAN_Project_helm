## 1.2.0 (April 16, 2025)
### Changed
- Forward SIGTERM in entrypoint script in ts2phc and phc2sys to ensure clean shutdown.
- Remove default namespace so the chart can be installed into any namespace.
- Update leapseconds file used by ts2phc for IEEE 1588 corrections.
- Improve printouts of liveness checks in ts2phc and phc2sys for better debugging.

## 1.1.0 (November 05, 2024)
### Changed
- Set `priorityClassName` to `system-node-critical` for both containers.
- Disable `ts2phc` by default to make it opt‑in.
- Update default image tag to the latest upstream linuxptp version.
- Add `ts2phc` container to the chart, with its own liveness probe script.

## 1.0.0 (Dezember 20, 2023)
### Log
- ptp4l and phc2sys running in seperatd containers.
- Moved config to values.yaml
- Added Liveness, Startup and Readiness probes
- Updated READMEs

## 0.1.0 (September 29, 2023)
### Added
- Initial release of the linuxptp Helm chart.
  - This chart facilitates the deployment of a linuxptp daemon running ptp4l and phc2sys.
