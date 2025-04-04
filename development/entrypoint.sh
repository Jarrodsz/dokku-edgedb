#!/bin/bash
set -e

# Start SSH server
service ssh start

# Configure Dokku if needed
if [ ! -f "/.dokku_configured" ]; then
    echo "Configuring Dokku for first run..."
    
    # Create required directories
    mkdir -p /home/dokku
    mkdir -p /var/lib/dokku/plugins/available
    mkdir -p /var/lib/dokku/plugins/enabled
    
    # Create the host key
    echo "dokku.me" > /home/dokku/HOSTNAME
    
    # Setup plugin
    ln -sf /var/lib/dokku/plugins/dokku-gel /var/lib/dokku/plugins/available/gel
    ln -sf /var/lib/dokku/plugins/available/gel /var/lib/dokku/plugins/enabled/gel
    
    # Run plugin install (with error handling)
    dokku plugin:install || echo "Plugin installation failed, but continuing..."
    
    # Mark as configured
    touch /.dokku_configured
fi

echo "====================================================="
echo "Dokku Development Environment"
echo "====================================================="
echo "SSH access: ssh root@localhost -p \$SSH_PORT (password: dokku)"
echo "Dokku version: $(dokku version || echo 'unknown - dokku may not be properly installed')"
echo "====================================================="
echo "To run tests: ./run-tests.sh"
echo "====================================================="

# Keep container running
exec tail -f /dev/null 