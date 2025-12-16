#!/bin/bash

# Troubleshooting script for Docker network issues

echo "======================================"
echo "  Docker Network Troubleshooting"
echo "======================================"
echo ""

echo "1. Checking Docker daemon status..."
if sudo systemctl is-active --quiet docker; then
    echo "   ✓ Docker daemon is running"
else
    echo "   ✗ Docker daemon is not running"
    echo "   Starting Docker..."
    sudo systemctl start docker
fi

echo ""
echo "2. Checking Docker configuration..."
if [ -f /etc/docker/daemon.json ]; then
    echo "   Current daemon.json:"
    cat /etc/docker/daemon.json
else
    echo "   No daemon.json found"
fi

echo ""
echo "3. Testing network connectivity..."
if ping -c 2 8.8.8.8 > /dev/null 2>&1; then
    echo "   ✓ IPv4 connectivity works"
else
    echo "   ✗ IPv4 connectivity failed"
fi

if ping -c 2 2001:4860:4860::8888 > /dev/null 2>&1; then
    echo "   ✓ IPv6 connectivity works"
else
    echo "   ✗ IPv6 connectivity failed (this may be causing the issue)"
fi

echo ""
echo "4. Testing Docker Hub connectivity..."
if curl -s --max-time 5 https://registry.hub.docker.com/v2/ > /dev/null; then
    echo "   ✓ Can reach Docker Hub"
else
    echo "   ✗ Cannot reach Docker Hub"
fi

echo ""
echo "======================================"
echo "  Recommended Solutions"
echo "======================================"
echo ""
echo "Option 1: Disable IPv6 for Docker"
echo "Create/edit /etc/docker/daemon.json with:"
echo ""
echo '{
  "ipv6": false,
  "dns": ["8.8.8.8", "8.8.4.4"]
}'
echo ""
echo "Then restart Docker:"
echo "  sudo systemctl restart docker"
echo ""
echo "Option 2: Use local Ubuntu image if available"
echo "  docker images | grep ubuntu"
echo ""
echo "Option 3: Pull image manually with IPv4"
echo "  sudo docker pull ubuntu:22.04"
echo ""
echo "======================================"
