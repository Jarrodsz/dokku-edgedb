#!/bin/bash
set -e

echo "🔥 Setting up Ignite with EdgeDB 🔥"
echo "===================================="

# Variables
DOCKER_CONTAINER="dokku-gel-dev"
APP_NAME="ignite"
DB_NAME="edgedb-ignite"

# Step 1: Destroy existing Docker container
echo "Step 1: Removing existing Docker container..."
/Applications/Docker.app/Contents/Resources/bin/docker rm -f $DOCKER_CONTAINER || echo "Container not found, continuing..."

# Step 2: Create new Docker container
echo "Step 2: Creating new Docker container..."
/Applications/Docker.app/Contents/Resources/bin/docker run -d --name $DOCKER_CONTAINER -p 3000:80 -p 5656:5656 -p 5001:5000 -it dokku/dokku:0.35.0

# Step 3: Wait for container to be ready
echo "Step 3: Waiting for container to be ready..."
sleep 10

# Step 4: Install EdgeDB/Gel in the container
echo "Step 4: Installing EdgeDB/Gel in the container..."
/Applications/Docker.app/Contents/Resources/bin/docker exec -it $DOCKER_CONTAINER bash -c "
  # Update and install dependencies
  apt-get update
  apt-get install -y curl apt-transport-https ca-certificates gnupg

  # Install EdgeDB/Gel
  curl https://packages.geldata.com/public-key.asc | apt-key add -
  echo 'deb https://packages.geldata.com/ /' > /etc/apt/sources.list.d/gel.list
  apt-get update
  apt-get install -y gel-server-6
  
  # Configure EdgeDB/Gel
  echo 'GEL_SERVER_SECURITY=insecure_dev_mode' > /etc/gel/env
  systemctl start gel
  
  # Install EdgeDB client
  npm install -g edgedb
"

# Step 5: Create the app and database
echo "Step 5: Creating app and database in Dokku..."
/Applications/Docker.app/Contents/Resources/bin/docker exec -it $DOCKER_CONTAINER bash -c "
  # Create the Dokku app
  dokku apps:create $APP_NAME
  
  # Create the EdgeDB database
  dokku gel:create $DB_NAME
  
  # Link the EdgeDB database to the app
  dokku gel:link $DB_NAME $APP_NAME
  
  # Show the environment variables for verification
  echo 'Dokku app created and database linked.'
  echo 'Environment variables:'
  dokku config:show $APP_NAME | grep -E 'GEL|DATABASE|EDGE' || echo 'No EdgeDB environment variables found'
"

# Step 6: Create app directory
echo "Step 6: Creating app directory structure..."
/Applications/Docker.app/Contents/Resources/bin/docker exec -it $DOCKER_CONTAINER bash -c "
  mkdir -p /home/dokku/$APP_NAME
"

# Step 7: Deploy the app
echo "Step 7: Deploying the application..."
./deploy-to-dokku.sh

echo "✅ Ignite setup complete!"
echo "You can access the application at: http://localhost:5001/"
echo "To check logs: docker exec -it $DOCKER_CONTAINER bash -c 'cat /home/dokku/$APP_NAME/app.log'" 