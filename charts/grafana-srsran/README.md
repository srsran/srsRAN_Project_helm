# srsRAN Grafana Helm Chart

A Helm chart for srsRAN Grafana with InfluxDB 3 and Telegraf

This Helm chart deploys Grafana with srsRAN Dashboards using InfluxDB 3 and Telegraf for metrics.

## Installing the Chart

To install the chart with the release name `grafana`:

```console
cd charts/grafana-srsran
helm install grafana ./
```

## Uninstalling the Chart

To uninstall/delete the grafana deployment:

```console
helm delete grafana
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| grafana.image.repository | string | `"softwareradiosystems/grafana"` | Grafana image repository |
| grafana.image.tag | string | `"11c9bbabb6__2025-09-15"` | Grafana image tag |
| grafana.env.GF_VERSION | string | `"12.0.2"` | Grafana version |
| grafana.env.GF_PORT | string | `"3000"` | Grafana port |
| grafana.env.GF_AUTH_ANONYMOUS_ENABLED | string | `"true"` | Enable anonymous access |
| grafana.env.GF_AUTH_ANONYMOUS_ORG_ROLE | string | `"Viewer"` | Anonymous user role |
| grafana.env.GF_SECURITY_ADMIN_USER | string | `"admin"` | Admin username |
| grafana.env.GF_SECURITY_ADMIN_PASSWORD | string | `"admin1234"` | Admin password |
| grafana.env.INFLUXDB3_EXTERNAL_URL | string | `"http://influxdb3.srsran.svc.cluster.local:8081"` | InfluxDB 3 external URL |
| grafana.env.INFLUXDB3_AUTH_TOKEN | string | `"fake-token-1234567890abcdef"` | InfluxDB 3 auth token |
| grafana.env.INFLUXDB3_BUCKET | string | `"srsran"` | InfluxDB 3 bucket name |
| grafana.service.enabled | bool | `true` | Enable Grafana service |
| grafana.service.type | string | `"NodePort"` | Service type |
| grafana.service.port | int | `80` | Service port |
| grafana.service.targetPort | int | `3000` | Target port |
| grafana.service.nodePort | int | `30001` | Node port |
| influxdb3.image.repository | string | `"influxdb"` | InfluxDB 3 image repository |
| influxdb3.image.tag | string | `"3.1.0-core"` | InfluxDB 3 image tag |
| influxdb3.service.type | string | `"ClusterIP"` | InfluxDB 3 service type |
| influxdb3.service.port | int | `8081` | InfluxDB 3 service port |
| influxdb3.database.name | string | `"srsran"` | InfluxDB 3 database name |
| influxdb3.persistence.enabled | bool | `true` | Enable InfluxDB 3 persistence |
| influxdb3.persistence.type | string | `"hostPath"` | Persistence type |
| influxdb3.persistence.hostPath | string | `"/mnt/influxdb3"` | Host path for data storage |
| influxdb3.persistence.accessMode | string | `"ReadWriteOnce"` | Access mode |
| influxdb3.persistence.size | string | `"50Gi"` | Storage size |
| influxdb3.persistence.mountPath | string | `"/var/lib/influxdb3"` | Data mount path |
| influxdb3.persistence.pluginMountPath | string | `"/var/lib/influxdb3-plugins"` | Plugin mount path |
| telegraf.useImageConfig | bool | `true` | Use image config for Telegraf |
| telegraf.image.repo | string | `"softwareradiosystems/telegraf"` | Telegraf image repository |
| telegraf.image.tag | string | `"11c9bbabb6__2025-09-15"` | Telegraf image tag |
| telegraf.env.WS_URL | string | `"srsran-project-cudu-chart-metrics.srsran.svc.cluster.local:8001"` | WebSocket URL |
| telegraf.env.INFLUXDB3_EXTERNAL_URL | string | `"http://influxdb3.srsran.svc.cluster.local:8081"` | InfluxDB 3 URL for Telegraf |
| telegraf.env.INFLUXDB3_AUTH_TOKEN | string | `"fake-token-1234567890abcdef"` | InfluxDB 3 auth token for Telegraf |
| telegraf.env.INFLUXDB3_BUCKET | string | `"srsran"` | InfluxDB 3 bucket for Telegraf |
| telegraf.env.TELEGRAF_INPUT_INTERVAL | string | `"1s"` | Input interval |
| telegraf.env.TELEGRAF_OUTPUT_INTERVAL | string | `"1s"` | Output interval |
| telegraf.env.TELEGRAF_BUFFER_LIMIT | string | `"10000"` | Buffer limit |
| telegraf.service.enabled | bool | `false` | Enable Telegraf service |

For more information about Grafana configuration, please refer to the [Grafana Documentation](https://grafana.com/docs/).

