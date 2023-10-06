# SRSran Helm Charts and Docker Images Repository

## Overview

Welcome to the srsRAN Project Helm Charts and Docker Images repository! This repository is dedicated to providing Helm charts for Kubernetes deployments of the srsRAN Project's CU/DU applocation. Additionally, it houses the Docker images that can be deployed using these Helm charts.

## Helm Charts

### Chart Structure

- **srsran-cudu**: Helm chart for deploying the srsRAN CU/DU.

### Installation

To deploy the srsRAN CU/DU application using Helm, follow these steps:

1. [Install Helm](https://helm.sh/docs/intro/install/).
2. Clone this repository:

   ```bash
   git clone https://github.com/your-username/srsran-helm-charts.git

3. Navigate to the respective chart directory.

4. Customize the chart values in the values.yaml file as needed.

5. Install the chart:
    ```bash
    helm install srsran-cudu ./ --namespace srsran

6. Monitor the deployment:
    ```bash
    kubectl get pods -n srsran

## Docker Images

### Images

Docker images for the srsRAN CU/DU are available on [AWS ECR](166552988672.dkr.ecr.eu-west-1.amazonaws.com/srsgnb-k8s-ubuntu). You can pull these images to use with the Helm charts or in your custom Kubernetes deployments.

#### Example:

To pull the srsRAN CU/DU Docker image, run:

```bash
docker pull 166552988672.dkr.ecr.eu-west-1.amazonaws.com/srsgnb-k8s-ubuntu:2023.5_0.0.4-amd64
