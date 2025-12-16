#!/bin/bash

# Script to stop and remove all Roundcube Docker containers

set -e

echo "Stopping Roundcube Mail Docker containers..."

# Determine docker-compose command
if docker compose version &> /dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

$DOCKER_COMPOSE down

echo ""
echo "Containers stopped and removed successfully!"
echo ""
echo "To remove volumes as well (WARNING: This deletes all data):"
echo "  $DOCKER_COMPOSE down -v"
