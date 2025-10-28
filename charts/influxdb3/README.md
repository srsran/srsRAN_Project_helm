# InfluxDB 3 Helm Chart

A Helm chart for InfluxDB 3

This Helm chart deploys a simple, single-node InfluxDB 3 instance in Kubernetes.

## Installing the Chart

In case you want to use persistant storage using a hostPath volume, make sure the needed directory exists on your node and has the correct permissions (default: `/mnt/influxdb3-plugins`):

```console
sudo mkdir -p /mnt/influxdb3-plugins
sudo chown -R 1000:1000 /mnt/influxdb3-plugins
sudo chmod -R 0775 /mnt/influxdb3-plugins
```

In order to write to this directory make sure you have the following snippet in your values.yaml file:

```yaml
  securityContext:
    runAsUser: 1000
    runAsGroup: 1000
```

To install the chart with the release name `influxdb3`:

```console
cd charts/influxdb3
helm install influxdb3 ./
```

## Uninstalling the Chart

To uninstall/delete the influxdb3 deployment:

```console
helm delete influxdb3
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Pod affinity configuration |
| annotations | object | `{}` | Annotations for the Deployment |
| securityContext | object | `{}` | Container security context (allowPrivilegeEscalation, etc.) |
| fullnameOverride | string | `""` | Overrides the chart's computed fullname |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.pullSecrets | list | `[]` | Image pull secrets |
| image.repository | string | `"influxdb"` | Image repository |
| image.tag | string | `"3.1.0-core"` | Image tag |
| nameOverride | string | `""` | Overrides the chart's name |
| nodeSelector | object | `{}` | nodeSelector configuration |
| podAnnotations | object | `{}` | Annotations for the Deployment Pods |
| podSecurityContext | object | `{}` | Pod security context (runAsUser, etc.) |
| resources | object | `{}` | Resource limits and requests config |
| service.type | string | `"ClusterIP"` | Service type |
| service.port | int | `8081` | Service port |
| persistence.enabled | bool | `true` | Enable persistence |
| persistence.accessMode | string | `"ReadWriteOnce"` | Access mode for persistent volume |
| persistence.size | string | `"50Gi"` | Size of persistent volume |
| persistence.mountPath | string | `"/var/lib/influxdb3"` | Mount path for data directory |
| persistence.pluginMountPath | string | `"/var/lib/influxdb3-plugins"` | Mount path for plugins directory |
| persistence.hostPath | string | `"/mnt/influxdb3"` | Host path for data storage |
| env.LOG_FILTER | string | `"error"` | Log filter level |
| env.INFLUXDB_NODE_ID | string | `"node0"` | InfluxDB node ID |
| args | list | `["--object-store=memory", "--data-dir=/var/lib/influxdb3", "--plugin-dir=/var/lib/influxdb3-plugins", "--node-id=node0", "--http-bind=0.0.0.0:8081", "--without-auth"]` | InfluxDB command line arguments |

For more information about InfluxDB 3 configuration, please refer to the [InfluxDB 3 Documentation](https://docs.influxdata.com/influxdb/v3/).
