# Containerized WebAPI Demo

This demo demonstrates the creation, deployment and execution of a simple web API application into a local containerized environment.

## Development Setup

### 1. Install Docker

Make sure Docker is installed and running on your system.

* [Docker Engine Overview](https://docs.docker.com/engine/install/)
* [Install on macOS](https://docs.docker.com/desktop/setup/install/mac-install/)
* [Install on Windows](https://docs.docker.com/desktop/setup/install/windows-install/)
* [Install on Linux](https://docs.docker.com/desktop/setup/install/linux/)

### 2. Managing the Development Environment

The project includes a `scripts/dev-env.sh` script that manages the lifecycle of your containerized web API development environment. This script handles building, starting, stopping, and restarting two separate container instances with configurable settings.

#### Script Overview

The `scripts/dev-env.sh` script provides three main commands:

* **start**: Builds the Docker image and starts two containers
* **stop**: Stops and removes running containers
* **restart**: Stops existing containers and starts fresh ones

#### Basic Usage

Start the development environment with default settings:

```bash
./dev-env.sh start
```

Stop the development environment:

```bash
./dev-env.sh stop
```

Restart the development environment:

```bash
./dev-env.sh restart
```

#### Default Configuration

By default, the script creates two containers with the following settings:

| Setting                     | Value                                              |
| --------------------------- | -------------------------------------------------- |
| Container Names             | `containerized-webapi-1`, `containerized-webapi-2` |
| Host Port (Container 1)     | `8081`                                             |
| Host Port (Container 2)     | `8082`                                             |
| Internal API Container Port | `5001`                                             |
| API Value                   | "This is a fun project"                            |

#### Customizing the Environment

You can override default values using command-line arguments:

Change the internal API port:

```bash
./dev-env.sh start --api_port 3000
```

Customize API values for each container:

```bash
./dev-env.sh start --api_value "Hello world"
```

Change the container name prefix:

```bash
./dev-env.sh start --container_name my-custom-api
```

Combine multiple options:

```bash
./dev-env.sh start --api_port 6000 --api_value "Dit is 'n pret projek"
```

#### Available Options

| Option             | Description                                                | Default                 |
| ------------------ | ---------------------------------------------------------- | ----------------------- |
| `--api_port`       | Internal port the API listens on in container 1            | `5001`                  |
| `--api_value`      | Environment variable value for container 1                 | "This is a fun project" |
| `--container_name` | Base name for containers (will be suffixed with -1 and -2) | `containerized-webapi`  |

#### Accessing the API

Once started, the two container instances are accessible at:

* **Container 1**: `http://127.0.0.1:8081`
* **Container 2**: `http://127.0.0.1:8082`

#### Troubleshooting

Containers won't start:

* Ensure Docker is running
* Check if ports 8081 and 8082 are already in use

Changes not reflected:

* Run `./dev-env.sh restart` to rebuild the image and restart containers
* Use `docker images` to verify the image was rebuilt

---

## Kubernetes Deployment

This project can also be deployed to a Kubernetes cluster for testing or demonstration purposes. The deployment uses a **Deployment** and a **Service** to run the containerized Web API application with multiple replicas.

### 1. Prerequisites

* Kubernetes cluster running (e.g., Docker Desktop, Minikube, or Rancher Desktop)
* `kubectl` CLI installed and configured

### 2. Deployment Script

The project includes a `scripts/manage-k8s.sh` script that automates deployment:

* Applies Namespace, ConfigMap, Deployment, and Service manifests
* Waits for the Deployment rollout to complete
* Displays all resources in the target namespace

#### Usage

1. Deploy to the default namespace (`flask-app`):
2. Remove all resources from project
3. Upgrade resources

```bash
./manage-k8s.sh deploy
./manage-k8s.sh scrap
./manage-k8s.sh upgrade
```

### 3. Deployment Details

The Kubernetes Deployment is configured with the following:

| Setting               | Value                                               |
| --------------------- | --------------------------------------------------- |
| Deployment Name       | `containerized-webapi-deployment`                   |
| Namespace             | `flask-app`                                         |
| Replicas              | `2`                                                 |
| Container Name        | `containerized-webapi`                              |
| Container Image       | `ghcr.io/josh1205/containerized-webapi:v1.0.1`      |
| Container Port        | `5001`                                              |
| Environment Variables | `WEB_API_PORT`, `WEB_API_VALUE` (from ConfigMap)    |
| Service Type          | `NodePort` (exposes pods externally on a node port) |

### 4. Accessing the API

After deployment, the Service exposes the application on a NodePort. You can check the assigned port with:

```bash
kubectl get svc -n flask-app
```

Then access the endpoints:

* Health check: `http://127.0.0.1:30080/health`
* Value endpoint: `http://127.0.0.1:30080/value`

### 5. Verifying Deployment

Check all resources in the namespace:

```bash
kubectl get all -n flask-app
```

Check rollout status of the deployment:

```bash
kubectl rollout status deployment/containerized-webapi-deployment -n flask-app
```
