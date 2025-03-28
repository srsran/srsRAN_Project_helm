# rt-tests

A Helm chart for rt-tests tool

## Installing the Chart

To install the chart with the release name `my-release`:

```console
cd charts/rt-tests
helm install my-release ./
```

## Uninstalling the Chart

To uninstall/delete the my-release deployment:

```console
helm delete my-release
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
| image.repository | string | `"softwareradiosystems/rt-tests"` | Image repository |
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
| hostOutputFolder | string | `"/var/lib/rt-tests"` | Path to store results in the host |
| config | section | `[]` | Configuration for the rt-tests tool |

### Config

The configuration file rt_tests.yml is used to specify the tools that will run in parallel within the container. Each entry in the file corresponds to an executable (the tool to run) and the arguments that will be passed to it.

For example:

```yml
config:
  rt_tests.yml: |-
    stress-ng: "--matrix 0 -t 12h"
    cyclictest: "-m -p95 -d0 -a 1-15 -t 16 -h400 -D 12h"
```

In this example:

- stress-ng will be executed with the arguments --matrix 0 -t 12h.
- cyclictest will be executed with the arguments -m -p95 -d0 -a 1-15 -t 16 -h400 -D 12h.

Notes:

- The script launches each defined process in parallel, allowing all specified tools to run simultaneously.
- The container will remain active until all launched processes have completed. Once all the tools finish their execution, the container will terminate.
- Only binaries available in the container's PATH can be executed.
- You can modify the rt_tests.yml file to add, remove, or adjust the entries as needed.

This configuration allows you to automate and manage multiple tests or tools—such as performance or stress tests—efficiently within the container.
