# Helm Charts Collection of srsRAN

This repo mantains Helm charts of srsRAN.

Refer to the README.md of each chart to for more information.

## Install charts from Helm repository

All Charts in the `charts/` folder of the GitHub repo are packaged and available in the srsRAN Project Helm repo:  

[https://github.com/srsran/srsRAN_Project_helm/](https://github.com/srsran/srsRAN_Project_helm/)

You can add the Helm repository to your Helm CLI with the following command:

```bash
helm repo add srsran https://srsran.github.io/srsRAN_Project_helm/
```

Then you have a collection of charts available to install. For example, to install the Linuxptp agent:

```bash
helm install linuxptp srsran/linuxptp
```

## Install chart from release file

Install charts using the URL of the release file. For example, to install the linuxptp v1.0.0 chart:

```bash
helm install https://github.com/srsran/srsRAN_Project_helm/releases/download/liuxptp-v1.0.0/linuxptp-1.0.0.tgz
```
