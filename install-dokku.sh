#!/bin/bash
set -eo pipefail

echo "Installing Dokku in Docker container..."

# First, remove any existing Dokku repositories
apt-get remove -y dokku || true
rm -rf /etc/apt/sources.list.d/dokku* /etc/apt/trusted.gpg.d/dokku* /etc/apt/keyrings/dokku* /var/lib/apt/lists/*

# Make sure we have wget and other dependencies
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y wget gnupg apt-transport-https

# Clean up any existing installation
rm -f /usr/local/bin/dokku

# Use the official bootstrap script to install Dokku
cd /root
wget -NP . https://raw.githubusercontent.com/dokku/dokku/master/bootstrap.sh
DOKKU_TAG=v0.35.16 bash bootstrap.sh

# Skip interactive prompts
export DEBIAN_FRONTEND=noninteractive
echo "dokku dokku/skip_key_file boolean true" | debconf-set-selections
echo "dokku dokku/vhost_enable boolean false" | debconf-set-selections
echo "dokku dokku/web_config boolean false" | debconf-set-selections
echo "dokku dokku/hostname string dokku-host" | debconf-set-selections

# Create plugin directories if they don't exist
mkdir -p /var/lib/dokku/plugins/available /var/lib/dokku/plugins/enabled /var/lib/dokku/services/gel

# Verify installation
dokku version

echo "Dokku installation complete." 