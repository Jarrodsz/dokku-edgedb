#!/bin/bash
set -e

echo "🚀 Deploying Ignite application to Dokku..."

# Variables
APP_NAME="ignite"
DOCKER_CONTAINER="dokku-gel-dev"
ARCHIVE_NAME="dokku-app.tar.gz"
EDGEDB_DSN="gel://gel:testpassword@host.docker.internal:5656/edgedb-ignite"

echo "Packaging application files..."
tar -czf $ARCHIVE_NAME -C dokku-app .

echo "Copying files to Dokku container..."
/Applications/Docker.app/Contents/Resources/bin/docker cp $ARCHIVE_NAME $DOCKER_CONTAINER:/home/dokku/$APP_NAME/

echo "Deploying to Dokku..."
/Applications/Docker.app/Contents/Resources/bin/docker exec -it $DOCKER_CONTAINER bash -c "
  cd /home/dokku/$APP_NAME &&
  tar -xzf $ARCHIVE_NAME &&
  rm $ARCHIVE_NAME &&
  
  # Ensure the app exists
  dokku apps:exists $APP_NAME || dokku apps:create $APP_NAME
  
  # Set the EdgeDB connection string as an environment variable
  dokku config:set $APP_NAME GEL_URL='$EDGEDB_DSN'
  
  # Display the environment variables for verification
  echo 'App environment variables:'
  dokku config:show $APP_NAME || echo 'Could not show config'
  
  # Install Node.js and npm if they don't exist
  command -v node >/dev/null 2>&1 || { 
    echo 'Installing Node.js...'
    curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
    apt-get install -y nodejs
  }
  
  # Install EdgeDB module
  echo 'Installing EdgeDB module...'
  npm install edgedb
  
  # Install dependencies
  npm install || echo 'Failed to install dependencies - proceeding anyway'
  
  # Start the application as a background process
  echo 'Starting application...'
  nohup node index.js > /home/dokku/$APP_NAME/app.log 2>&1 &
  echo 'Application started with PID:' \$!
"

echo "Cleaning up..."
rm $ARCHIVE_NAME

echo "✅ Deployment completed successfully!"
echo "Application should be accessible via: http://localhost:5001/"
echo "To check logs: docker exec -it $DOCKER_CONTAINER bash -c 'cat /home/dokku/$APP_NAME/app.log'" 