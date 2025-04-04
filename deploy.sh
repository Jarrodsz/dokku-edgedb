#!/bin/bash
set -e

# Variables
APP_NAME="edgedb-test-app"
DOCKER_CONTAINER="dokku-gel-dev"
TEMP_DIR=$(mktemp -d)
ARCHIVE_NAME="app.tar.gz"
APP_DIR="/home/dokku/$APP_NAME"

echo "🚀 Deploying application to Dokku..."
echo "Preparing application files..."

# Copy application files to the temporary directory
cp -r test-app/* $TEMP_DIR

echo "Creating archive..."
tar -czf $ARCHIVE_NAME -C $TEMP_DIR .
rm -rf $TEMP_DIR

echo "Copying to Dokku container..."
/Applications/Docker.app/Contents/Resources/bin/docker cp $ARCHIVE_NAME $DOCKER_CONTAINER:/tmp/$ARCHIVE_NAME

echo "Setting up application..."
/Applications/Docker.app/Contents/Resources/bin/docker exec -it $DOCKER_CONTAINER bash -c "
  # Verify Node.js version
  echo 'Node.js version:'
  node -v
  npm -v

  # Extract code to the app directory
  echo 'Extracting application files...'
  mkdir -p $APP_DIR
  tar -xzf /tmp/$ARCHIVE_NAME -C $APP_DIR
  chown -R dokku:dokku $APP_DIR

  # Get the database connection URL
  DATABASE_URL=\$(dokku gel:info edge-db-instance --dsn)
  echo \"EdgeDB connection URL: \$DATABASE_URL\"

  # Create a proper .env file with the connection URL
  echo \"Creating .env file...\"
  echo \"DATABASE_URL=\$DATABASE_URL\" > $APP_DIR/.env
  echo \"PORT=5000\" >> $APP_DIR/.env
  echo \"NODE_ENV=production\" >> $APP_DIR/.env
  cat $APP_DIR/.env

  # Kill any existing node processes for this app (if any)
  echo 'Stopping any existing server processes...'
  pkill -f 'node $APP_DIR/simple-server.js' || true
  pkill -f 'node.*simple-server.js' || true

  # Change to the app directory
  cd $APP_DIR
  
  # Make sure the .env file is readable
  chmod 644 .env
  
  # Start the simple server directly with environment variables
  echo 'Starting the simple server with explicit environment...'
  DATABASE_URL=\$DATABASE_URL PORT=5000 NODE_ENV=production node -e '
    console.log(\"Environment check:\");
    console.log(\"DATABASE_URL = \" + process.env.DATABASE_URL);
    console.log(\"PORT = \" + process.env.PORT);
    console.log(\"NODE_ENV = \" + process.env.NODE_ENV);
    console.log(\"Current directory: \" + process.cwd());
  '
  
  # Start the server in the background with explicit environment variables
  echo 'Starting the simple server...'
  DATABASE_URL=\$DATABASE_URL PORT=5000 NODE_ENV=production nohup node simple-server.js > server.log 2>&1 &
  
  # Wait a moment to make sure the server starts up
  echo 'Waiting for server to start...'
  sleep 5
  
  # Check if the process is running
  if pgrep -f 'node.*simple-server.js' > /dev/null; then
    echo 'Server process is running!'
  else
    echo 'WARNING: Server process not found!'
  fi
  
  # See if we have any logs
  if [ -f server.log ]; then
    echo 'Server log:'
    cat server.log
  else
    echo 'No server log file yet'
  fi
  
  # Test the server
  echo 'Testing server connection...'
  curl -s http://localhost:5000
"

echo "Cleaning up..."
rm $ARCHIVE_NAME

echo "✅ Deployment completed!"
echo "🌐 Application should be running in the Dokku container on port 5000" 