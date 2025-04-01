# srsRAN Project Metrics Server Helm Chart

A Helm chart for srsRAN Proect Metrics Server

This Helm chart deploys a metrics server that receives data from the srsRAN Project CU/DU and parses this for Grafana. The data is sent to an InfluxDB database.

## Installing the Chart

To install the chart with the release name `metrics-server`:

```console
cd charts/metrics_server
helm install metrics-server ./
```

## Uninstalling the Chart

To uninstall/delete the metrics-server deployment:

```console
helm delete metrics-server
```

The command removes all the Kubernetes components associated with the chart and deletes the release.


## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Pod affinity configuration |
| annotations | object | `{}` | Annotations for the Deployment |
| securityContext | object | `{}` | Container security context (allowPrivilegeEscalation, etc.) |
| fullnameOverride | string | `""` | Overrides the chart's computed fullname |
| interfaceName | string | `{}` | Name of the interface to be used for ptp4l |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.pullSecrets | list | `[]` | Image pull secrets |
| image.repository | string | `"srsran/metrics-server"` | Image repository |
| image.tag | string | `""` | Image tag |
| nameOverride | string | `""` | Overrides the chart's name |
| nodeSelector | object | `{}` | nodeSelector configuration |
| podAnnotations | object | `{}` | Annotations for the Deployment Pods |
| podSecurityContext | object | `{}` | Pod security context (runAsUser, etc.) |
| resources | object | `{}` | Resource limits and requests config |
| serviceAccount.annotations | object | `{}` | Annotations for service account |
| serviceAccount.create | bool | `true` | Toggle to create ServiceAccount |
| serviceAccount.name | string | `nil` | Service account name |
| tolerations | list | `[]` | Tolerations applied to Pods |
| config | section | `[]` | Configuration for the metrics-server |
