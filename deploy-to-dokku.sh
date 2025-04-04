#!/bin/bash
set -e

echo "🚀 Deploying Ignite application to Dokku..."

# Variables
APP_NAME="ignite"
DB_NAME="edgedb-ignite"
DOCKER_CONTAINER="dokku-gel-dev"
ARCHIVE_NAME="dokku-app.tar.gz"

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
  
  # Ensure EdgeDB service exists and is linked to the app
  dokku gel:info $DB_NAME || dokku gel:create $DB_NAME
  
  # Link the EdgeDB service to the app (this sets environment variables for connection)
  dokku gel:link $DB_NAME $APP_NAME
  
  # Display the environment variables for verification
  echo 'App environment variables:'
  dokku config:show $APP_NAME | grep -E 'GEL|DATABASE|EDGE' || echo 'No EdgeDB environment variables found'
  
  # Install dependencies
  npm install
  
  # Set additional configuration (optional)
  # dokku config:set $APP_NAME KEY=VALUE
  
  # Restart the app to apply changes
  dokku ps:restart $APP_NAME || echo 'App restart not available in this environment'
  
  # Start the application as a background process if direct restart fails
  if ! dokku ps:restart $APP_NAME &>/dev/null; then
    echo 'Starting application manually...'
    nohup node index.js > /home/dokku/$APP_NAME/app.log 2>&1 &
    echo 'Application started with PID:' \$!
  fi
"

echo "Cleaning up..."
rm $ARCHIVE_NAME

echo "✅ Deployment completed successfully!"
echo "Application should be accessible via the Dokku URL"
echo "To check logs: docker exec -it $DOCKER_CONTAINER bash -c 'cat /home/dokku/$APP_NAME/app.log'" 