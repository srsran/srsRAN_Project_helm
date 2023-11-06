# srsRAN Docker Images

This repository contains instructions for building srsRAN Docker images. These Docker images can be customized for various purposes. Follow the steps below to build your own Docker images. Pre-built versions of these images are availble on [Docker Hub](https://hub.docker.com/u/softwareradiosystems).

## Prerequisites

Before you begin, ensure that you have the following prerequisites installed on your system:

- [Docker](https://www.docker.com/get-started) - Ensure you have Docker installed and configured on your machine.

## Building Docker Images

1. Clone this repository and change your working directory:

   ```shell
   git clone https://github.com/srsran/helm-charts.git
   ```

2. Change your working directory to the descired image.
    Example:

    ```shell
    cd helm-charts/images/Ubuntu-2204/OFH
    ```

3. Customize the Dockerfile:

    You can modify the Dockerfile to include the necessary components, libraries, and configurations for your specific needs.

4. Build the Docker image using the docker build command. Replace your-image-name:your-tag with a meaningful name and tag for your image:

    ```shell
    docker build -t your-image-name:your-tag .
   ```

    For example, if you are creating a web server image, you might use something like:

    ```shell
    docker build -t srsran-project-cudu:latest .
    ```

5. Once the build process is complete, you can verify that your image was created by running:

    ```shell
    docker images
    ```

    This command will list all available Docker images on your system, and you should see your newly built image in the list. For specific instructions on each image please refer to their respective README.md files.
