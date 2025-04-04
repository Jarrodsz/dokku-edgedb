# Dokku GEL Plugin Development Environment

This directory contains scripts to set up a local development environment for testing the Dokku GEL plugin in a Docker container.

## Prerequisites

- Docker installed and running on your system
- Bash shell environment

## Quick Start

To set up the development environment:

```bash
# Make scripts executable
chmod +x development/*.sh

# Build and start the container
./development/setup.sh
```

## Available Scripts

- `setup.sh`: Builds and starts the Dokku development container
- `connect.sh`: Opens a terminal into the container
- `run-tests.sh`: Runs the plugin tests inside the container

## Running Tests

To run all tests:

```bash
./development/run-tests.sh
```

To run a specific test file:

```bash
./development/run-tests.sh "tests/service_create.bats"
```

## Container Details

- SSH Access: `ssh root@localhost -p 2222` (password: `dokku`)
- The plugin code is mounted at `/var/lib/dokku/plugins/dokku-gel`
- Dokku version: v0.32.0
- Port mappings: SSH on 2222, app ports on 3000-10000

## Troubleshooting

If tests fail, you can connect to the container to debug:

```bash
./development/connect.sh
cd /var/lib/dokku/plugins/dokku-gel
``` 