#!/bin/bash

# Quick fix script for Docker IPv6 network issue

set -e

echo "======================================"
echo "  Fixing Docker Network Issue"
echo "======================================"
echo ""

# Backup existing daemon.json if it exists
if [ -f /etc/docker/daemon.json ]; then
    echo "Backing up existing /etc/docker/daemon.json..."
    sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.backup
    echo "✓ Backup created: /etc/docker/daemon.json.backup"
fi

echo ""
echo "Creating/updating Docker daemon configuration..."

# Create daemon.json with IPv6 disabled
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "ipv6": false,
  "dns": ["8.8.8.8", "8.8.4.4"],
  "registry-mirrors": []
}
EOF

echo "✓ Configuration updated"
echo ""
echo "Restarting Docker daemon..."
sudo systemctl restart docker

echo "✓ Docker restarted"
echo ""
echo "Waiting for Docker to be ready..."
sleep 3

if sudo systemctl is-active --quiet docker; then
    echo "✓ Docker is running"
    echo ""
    echo "======================================"
    echo "  Fix Applied Successfully!"
    echo "======================================"
    echo ""
    echo "You can now run: ./deploy.sh"
else
    echo "✗ Docker failed to start"
    echo ""
    echo "Please check Docker logs:"
    echo "  sudo journalctl -u docker -n 50"
    exit 1
fi
