# Containerized WebAPI Demo

This demo demonstrates the creation, deployment and execution of a simple web API application into a local containerized environment.

## Development Setup

### 1. Install Docker

Make sure Docker is installed and running on your system.

- [Docker Engine Overview](https://docs.docker.com/engine/install/)
- [Install on macOS](https://docs.docker.com/desktop/setup/install/mac-install/)
- [Install on Windows](https://docs.docker.com/desktop/setup/install/windows-install/)
- [Install on Linux](https://docs.docker.com/desktop/setup/install/linux/)

### 2. Managing the Development Environment

The project includes a `dev-env.sh` script that manages the lifecycle of your containerized web API deveopment environment. This script handles building, starting, stopping, and restarting two separate container instances with configurable settings.

#### Script Overview

The `dev-env.sh` script provides three main commands:

- **start**: Builds the Docker image and starts two containers
- **stop**: Stops and removes running containers
- **restart**: Stops existing containers and starts fresh ones

#### Basic Usage

Start the development environment with default settings:

```bash
./dev-env.sh start
```

Stop the development environment:

```bash
./dev-env.sh stop
```

Restart the development environment (As of now command if the same as start. This was implemented in case extra logic would be added to restart):

```bash
./dev-env.sh restart
```

#### Default Configuration

By default, the script creates two containers with the following settings:

| Setting | Value |
|---------|-------|
| Container Names | `containerized-webapi-1`, `containerized-webapi-2` |
| Internal API Container 1 Port | `5000` |
| Internal API Container 2 Port | `5000` |
| Host Port (Container 1) | `8080` |
| Host Port (Container 2) | `8081` |
| API Value (Container 1) | "This is a fun project from Container 1" |
| API Value (Container 2) | "This is a fun project from Container 2" |

#### Customizing the Environment

You can override default values using command-line arguments:

Change the internal API port:

```bash
./dev-env.sh start --api_port_1 3000 --api_port_2 4000
```

Customize API values for each container:

```bash
./dev-env.sh start --api_value_1 "Hello from Container 1" --api_value_2 "Hello from Container 2"
```

Change the container name prefix:

```bash
./dev-env.sh start --container_name my-custom-api
```

Combine multiple options:

```bash
./dev-env.sh start --api_port_1 6000 --api_value_1 "This is from container 1" --api_value_2 "Dit is van houer 2"
```

#### Available Options

| Option | Description | Default |
|--------|-------------|---------|
| `--api_port_1` | Internal port the API listens on in container 1 | `5000` |
| `--api_port_2` | Internal port the API listens on in container 2 | `5000` |
| `--api_value_1` | Environment variable value for container 1 | "This is a fun project from Container 1" |
| `--api_value_2` | Environment variable value for container 2 | "This is a fun project from Container 2" |
| `--container_name` | Base name for containers (will be suffixed with -1 and -2) | `containerized-webapi` |

#### Accessing the API

Once started, the two container instances are accessible at:

- **Container 1**: `http://127.0.0.1:8080`
- **Container 2**: `http://127.0.0.1:8081`

#### Troubleshooting

Containers won't start:

- Ensure Docker is running
- Check if ports 8080 and 8081 are already in use

Changes not reflected:

- Run `./dev-env.sh restart` to rebuild the image and restart containers
- Use `docker images` to verify the image was rebuilt