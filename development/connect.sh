#!/bin/bash
set -e

CONTAINER_NAME="dokku-gel-dev"

# Check for Docker CLI on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Check common Docker CLI locations on macOS
    DOCKER_LOCATIONS=(
        "/usr/local/bin/docker"
        "/Applications/Docker.app/Contents/Resources/bin/docker"
        "$HOME/.docker/bin/docker"
        "/opt/homebrew/bin/docker"
    )
    
    DOCKER_CMD=""
    for loc in "${DOCKER_LOCATIONS[@]}"; do
        if [ -x "$loc" ]; then
            DOCKER_CMD="$loc"
            echo "Found Docker CLI at: $DOCKER_CMD"
            break
        fi
    done
    
    # Use the found Docker CLI directly
    if [ -n "$DOCKER_CMD" ]; then
        # Check if container is running
        if ! $DOCKER_CMD ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
            echo "Error: Container '${CONTAINER_NAME}' is not running."
            echo "Run './development/setup.sh' first to start the container."
            exit 1
        fi

        echo "Connecting to Dokku development container..."
        $DOCKER_CMD exec -it ${CONTAINER_NAME} bash
        exit $?
    fi
fi

# Function to run docker commands with sudo if needed (fallback for non-macOS)
run_docker() {
    if ! docker "$@" > /dev/null 2>&1; then
        if command -v sudo > /dev/null 2>&1; then
            sudo docker "$@"
        else
            echo "Error: Cannot run docker commands. Try running with sudo."
            exit 1
        fi
    else
        docker "$@"
    fi
}

# Check if container is running
if ! run_docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Error: Container '${CONTAINER_NAME}' is not running."
    echo "Run './development/setup.sh' first to start the container."
    exit 1
fi

echo "Connecting to Dokku development container..."
run_docker exec -it ${CONTAINER_NAME} bash 