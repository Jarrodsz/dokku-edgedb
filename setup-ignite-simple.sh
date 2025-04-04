#!/bin/bash
set -e

echo "🔥 Setting up Ignite with EdgeDB - Simple Version 🔥"
echo "=================================================="

# Variables
DOCKER_CONTAINER="dokku-gel-dev"
APP_NAME="ignite"
DB_NAME="edgedb-ignite"
OLD_APP_NAME="edgedb-test-app"
OLD_DB_NAME="edge-db-instance"

# Step 1: Clean up old app and create new app
echo "Step 1: Cleaning up old app and creating new app..."
/Applications/Docker.app/Contents/Resources/bin/docker exec -it $DOCKER_CONTAINER bash -c "
  # Remove the old app if it exists
  dokku apps:exists $OLD_APP_NAME && dokku apps:destroy $OLD_APP_NAME --force || echo 'Old app not found, continuing...'
  
  # Create the new app
  dokku apps:exists $APP_NAME || dokku apps:create $APP_NAME
  
  # Create app directory if it doesn't exist
  mkdir -p /home/dokku/$APP_NAME
"

# Step 2: Create/Clone EdgeDB Database
echo "Step 2: Setting up EdgeDB database..."
/Applications/Docker.app/Contents/Resources/bin/docker exec -it $DOCKER_CONTAINER bash -c "
  # Depending on the Dokku EdgeDB plugin, we'll attempt to clone or create the database
  dokku gel:exists $DB_NAME || (
    # If the old database exists, clone it
    if dokku gel:exists $OLD_DB_NAME; then
      echo 'Cloning existing EdgeDB database...'
      dokku gel:clone $OLD_DB_NAME $DB_NAME || dokku gel:create $DB_NAME
    else
      # Otherwise create a new database
      echo 'Creating new EdgeDB database...'
      dokku gel:create $DB_NAME
    fi
  )
  
  # Link the database to the app
  dokku gel:link $DB_NAME $APP_NAME
  
  # Show the environment variables for verification
  echo 'Dokku app created and database linked.'
  echo 'Environment variables:'
  dokku config:show $APP_NAME | grep -E 'GEL|DATABASE|EDGE' || echo 'No EdgeDB environment variables found'
"

# Step 3: Deploy the app
echo "Step 3: Deploying the application..."
./deploy-to-dokku.sh

echo "✅ Ignite setup complete!"
echo "You can access the application at: http://localhost:5001/"
echo "To check logs: docker exec -it $DOCKER_CONTAINER bash -c 'cat /home/dokku/$APP_NAME/app.log'" 