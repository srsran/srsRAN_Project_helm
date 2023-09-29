# srsRAN Project Helm Chart

This Helm chart deploys the srsRAN Project CU/DU as a single-binary solution for ORAN. Before deploying, please review the following important information:

## Configuration File

The configuration file for the CU/DU is located in the root directory of this Helm chart and is named `gnb-config.yml`. To configure the application, refer to the documentation provided at [srsRAN Project User Manual](https://docs.srsran.com/projects/project/en/latest/user_manuals/source/running.html).

## Choosing the Right Container Image

Select the appropriate container image based on your CPU flags and architecture. We support the following combinations:

- CPU Architectures: arm64 and amd64
- Operating Systems: Ubuntu 20.04 and RHEL 8
- CPU Flags: AVX512, AVX2+AVX512, and no AVX

You can find the available container images on Docker Hub at [srsRAN Project Docker Images](https://hub.docker.com/repositories/softwareradiosystems).

## Node Requirements

Before deploying the srsRAN Project CU/DU on a node, ensure the following requirements are met:

1. **PTP4l and PHC2SYS**: These services must be running, and the local hardware clock must be synchronized. This ensures accurate communcation between CU/DU and RU.

2. **Interface Binding**: The interface connected to the Radio Unit (RU) must be bound to a DPDK-compatible driver such as `igb_uio` or `vfio-pci`. For detailed instructions on interface binding, please refer to the DPDK documentation at [DPDK Interface Binding Guide](https://doc.dpdk.org/guides/tools/devbind.html).
