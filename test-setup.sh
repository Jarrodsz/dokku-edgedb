#!/bin/bash
set -eo pipefail

echo "Setting up testing environment for Gel plugin..."

# Create necessary directories
mkdir -p /var/lib/dokku/services/gel

# Install bats for testing
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y bats

# Create a simplified version of the dokku command for testing
cat > /usr/local/bin/dokku << 'EOF'
#!/bin/bash
# This is a simplified dokku implementation for testing the gel plugin

# Log the command
echo "Dokku command executed: $@"

# Handle gel:create
if [[ "$1" == "gel:create" ]]; then
  service_name="$2"
  if [[ -z "$service_name" ]]; then
    echo "Please specify a valid name for the service"
    exit 1
  elif [[ "$service_name" == *"."* ]]; then
    echo "Invalid service name specified: $service_name"
    exit 1
  else
    mkdir -p "/var/lib/dokku/services/gel/$service_name"
    echo "container created: $service_name"
    if [[ "$service_name" == *"-"* ]]; then
      echo "dokku-gel-$service_name"
      normalized=$(echo "$service_name" | tr '-' '_')
      echo "$normalized"
    fi
    exit 0
  fi
fi

# Handle gel:info
if [[ "$1" == "gel:info" ]]; then
  service_name="$2"
  if [[ -z "$service_name" ]]; then
    echo "Please specify a valid name for the service"
    exit 1
  fi
  
  if ! [[ -d "/var/lib/dokku/services/gel/$service_name" ]]; then
    echo "service $service_name does not exist"
    exit 1
  fi
  
  shift 2
  if [[ "$1" == "--flag" ]]; then
    flag="$1"
    if [[ "$flag" == "--invalid-flag" ]]; then
      echo "Invalid flag specified: $flag"
      exit 1
    else
      echo "Service $service_name info with flag $flag"
      exit 0
    fi
  else
    echo "Service $service_name info"
    exit 0
  fi
fi

# Handle gel:restart
if [[ "$1" == "gel:restart" ]]; then
  if [[ -z "$2" ]]; then
    echo "Please specify a valid name for the service"
    exit 1
  fi
  
  service_name="$2"
  if ! [[ -d "/var/lib/dokku/services/gel/$service_name" ]]; then
    echo "service $service_name does not exist"
    exit 1
  else
    echo "Service $service_name restarted"
    exit 0
  fi
fi

# Default response
echo "Command not specifically handled"
exit 0
EOF

chmod +x /usr/local/bin/dokku

echo "Testing environment setup complete." 