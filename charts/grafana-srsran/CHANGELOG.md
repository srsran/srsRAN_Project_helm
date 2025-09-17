# Changelog

## 1.3.0 (2025-09-17)

### Changed
- Replace metrics server with Telegraf
- Migrate from InfluxDB 2 to InfluxDB 3
- Expose Grafana UI as NodePort service

## 1.2.0 (April 17, 2025)
### Changed
- Update InfluxDB image and tag in `values.yaml`.
- Fix the metrics-server image name in the dashboard sidecar.
- Add a `README.md` for chart usage and values reference.
- Remove unnecessary fields (e.g. old sample datasources) from `values.yaml`.
- Add Changelog for the chart.

## 0.1.0 (June 04, 2024)
### Added
- Initial version of the srsRAN Grafana Helm chart

