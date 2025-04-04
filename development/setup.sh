#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONTAINER_NAME="dokku-gel-dev"
SSH_PORT=2222

# macOS specific checks
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS environment..."
    
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
    
    # If Docker app exists but CLI not found in PATH
    if [ -d "/Applications/Docker.app" ] && [ -z "$DOCKER_CMD" ]; then
        echo "Docker Desktop is installed, but the Docker CLI isn't in your PATH."
        echo "Checking if Docker app has been launched at least once..."
        
        # Try to find Docker CLI in app bundle
        APP_DOCKER="/Applications/Docker.app/Contents/Resources/bin/docker"
        if [ -x "$APP_DOCKER" ]; then
            echo "Found Docker CLI in Docker.app bundle."
            DOCKER_CMD="$APP_DOCKER"
            # Create docker function to use the full path
            docker() {
                "$DOCKER_CMD" "$@"
            }
        else
            echo "Please open Docker Desktop from your Applications folder and complete the initial setup."
            echo "Attempting to open Docker Desktop now..."
            open -a Docker
            echo ""
            echo "After Docker Desktop has started, please run this script again."
            exit 1
        fi
    elif [ -z "$DOCKER_CMD" ]; then
        # No Docker found
        echo "Error: Docker CLI not found and Docker Desktop is not installed at the standard location."
        echo "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop/"
        echo "After installation, make sure to open Docker Desktop at least once to complete setup."
        exit 1
    fi
    
    # Use the found Docker CLI if not in PATH
    if [ -n "$DOCKER_CMD" ] && ! command -v docker &> /dev/null; then
        docker() {
            "$DOCKER_CMD" "$@"
        }
    fi
    
    # Check if Docker Desktop is running
    if ! docker info &> /dev/null; then
        echo "Docker Desktop is installed but not running."
        echo "Please start Docker Desktop application from your Applications folder"
        echo "or click the Docker icon in your menu bar."
        echo ""
        echo "Attempting to start Docker Desktop automatically..."
        open -a Docker
        
        # Wait for Docker to start (max 60 seconds)
        echo "Waiting for Docker to start (this may take up to 60 seconds)..."
        for i in {1..30}; do
            if docker info &> /dev/null; then
                echo "Docker is now running!"
                break
            fi
            if [ $i -eq 30 ]; then
                echo "Timed out waiting for Docker to start."
                echo "Please start Docker Desktop manually and try again."
                exit 1
            fi
            sleep 2
        done
    fi
    
    # Fix for docker-credential-desktop not found in PATH
    if [ -d "/Applications/Docker.app" ]; then
        HELPER_DIR="/Applications/Docker.app/Contents/Resources/bin"
        if [ -x "$HELPER_DIR/docker-credential-desktop" ] && [[ ":$PATH:" != *":$HELPER_DIR:"* ]]; then
            echo "Adding Docker credential helper to PATH..."
            export PATH="$HELPER_DIR:$PATH"
        fi
        
        # Check for credential helper issues
        if ! docker pull ubuntu:22.04 &> /dev/null; then
            echo "Docker credential issue detected. Trying to fix..."
            
            # Fix 1: Check if Docker config exists
            CONFIG_DIR="$HOME/.docker"
            if [ ! -d "$CONFIG_DIR" ]; then
                mkdir -p "$CONFIG_DIR"
            fi
            
            # Fix 2: Try simplifying Docker config
            CONFIG_FILE="$CONFIG_DIR/config.json"
            if [ -f "$CONFIG_FILE" ]; then
                echo "Backing up Docker config to ${CONFIG_FILE}.bak"
                cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"
                
                # Create a minimal config that doesn't use the credential helper
                echo '{
  "auths": {},
  "credStore": "",
  "credsStore": "",
  "experimental": "disabled"
}' > "$CONFIG_FILE"
                echo "Created simplified Docker config"
            else
                # Create a minimal config
                echo '{
  "auths": {},
  "experimental": "disabled"
}' > "$CONFIG_FILE"
                echo "Created minimal Docker config"
            fi
            
            echo "Testing Docker pull again..."
            if ! docker pull ubuntu:22.04 &> /dev/null; then
                echo "Still having issues with Docker. Please try to:"
                echo "1. Open Docker Desktop"
                echo "2. Sign out and sign in again if you're logged in"
                echo "3. Try running this script again"
                exit 1
            fi
            echo "Docker credential issue fixed!"
        fi
    fi
else
    # Non-macOS Docker checks (original code)
    if ! docker info > /dev/null 2>&1; then
        echo "Error: Cannot access Docker. This could be due to one of the following reasons:"
        echo "  1. Docker daemon is not running (try starting Docker Desktop or service docker start)"
        echo "  2. You don't have permission to access the Docker socket"
        echo "     - On Linux, try running with sudo: sudo $0"
        echo "     - Or add your user to the docker group: sudo usermod -aG docker $USER"
        echo "       (you'll need to log out and back in for this to take effect)"
        echo "  3. Docker socket is in a non-standard location"
        echo ""
        echo "Attempting to use sudo to run docker commands..."
        
        # Try with sudo if available
        if command -v sudo > /dev/null 2>&1; then
            if sudo docker info > /dev/null 2>&1; then
                echo "Success! Docker is accessible with sudo. Continuing with setup..."
                # Define a function to run docker with sudo
                docker() {
                    sudo docker "$@"
                }
            else
                echo "Error: Still cannot access Docker even with sudo. Please ensure Docker is installed and running."
                exit 1
            fi
        else
            echo "Error: sudo command not available. Please ensure Docker is installed, running, and you have proper permissions."
            exit 1
        fi
    fi
fi

echo "Building Dokku development container..."
docker build -t ${CONTAINER_NAME}-image ${SCRIPT_DIR}

# Check if container already exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Container already exists, stopping and removing..."
    docker stop ${CONTAINER_NAME} > /dev/null 2>&1 || true
    docker rm ${CONTAINER_NAME} > /dev/null 2>&1 || true
fi

# Define safe ports that likely won't conflict with existing services
echo "Using dynamically assigned ports to avoid conflicts"

echo "Starting Dokku development container..."
docker run -d \
    --name ${CONTAINER_NAME} \
    --hostname dokku-gel-dev \
    --privileged \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v ${PROJECT_DIR}:/var/lib/dokku/plugins/dokku-gel \
    -p ${SSH_PORT}:22 \
    -p 5656:5656 \
    -p 9001:9001 \
    -p 9999:9999 \
    -e SSH_PORT=${SSH_PORT} \
    ${CONTAINER_NAME}-image

if [ $? -ne 0 ]; then
    echo "Trying alternative ports..."
    docker run -d \
        --name ${CONTAINER_NAME} \
        --hostname dokku-gel-dev \
        --privileged \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v ${PROJECT_DIR}:/var/lib/dokku/plugins/dokku-gel \
        -p ${SSH_PORT}:22 \
        -e SSH_PORT=${SSH_PORT} \
        ${CONTAINER_NAME}-image
fi

echo ""
echo "====================================================="
echo "Dokku Development Environment Setup Complete!"
echo "====================================================="
echo "Container Name: ${CONTAINER_NAME}"
echo "SSH access: ssh root@localhost -p ${SSH_PORT} (password: dokku)"
echo "Project mounted at: /var/lib/dokku/plugins/dokku-gel"
echo ""
echo "Use the following scripts:"
echo "  - ./development/connect.sh    # Enter the container"
echo "  - ./development/run-tests.sh  # Run tests inside the container"
echo "=====================================================" 