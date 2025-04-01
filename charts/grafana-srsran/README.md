# srsRAN Grafana Helm Chart

A Helm chart to deploy Grafana for srsRAN. 

This chart is designed to be used with the srsRAN project and provides multiple Grafana dashboards for monitoring and visualizing data from the srsRAN CU/DU application.

## Configuration

This chart installs the official Grafana, InfluxDB and srsRAN Metrics Server Helm charts. The values.yaml file contains the configuration for all 3 charts.

For configuring the Grafana chart use the following section:

```yaml
grafana:
  image:
    repository: softwareradiosystems/grafana
    pullPolicy: IfNotPresent
    tag: "latest"
```

For configuring the InfluxDB chart use the following section:

```yaml
influxdb:
  image:
    repository: influxdb
    tag: "2.7.4-alpine"
```

For configuring the srsRAN Metrics Server chart use the following section:

```yaml
metrics-server:
  image:
    repository: registry.gitlab.com/softwareradiosystems/srsgnb/metrics_server
    pullPolicy: IfNotPresent
    tag: 1.9.2
```

The default values.yaml file comes with a preconfiguration for all 3 charts. To make these settings work in your environment, you need to adjust the cluster domain in oder to properly resolve the hostnames. For more information refer to the official srsRAN Project documentation https://docs.srsran.com/projects/project/en/latest/tutorials/source/k8s/source/index.html#visualizing-network-kpis-using-grafana

## Exposing Grafana to the outside world

In order to access Grafana from outside the cluster, you need to expose the Grafana service. This can be done by setting the `service.type` to `LoadBalancer` in the values.yaml file.  Therefore, refer to the Grafana Helm Git repository https://github.com/grafana/helm-charts/blob/main/charts/grafana/values.yaml#L230
