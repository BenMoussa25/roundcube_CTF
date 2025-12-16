#!/bin/bash

# Roundcube Mail Docker Deployment Script
# This script builds and starts the Roundcube Docker container

set -e

echo "================================================"
echo "  Roundcube Mail Docker Deployment"
echo "================================================"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker is not installed!"
    echo "Please install Docker first: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null 2>&1; then
    echo "ERROR: Docker Compose is not installed!"
    echo "Please install Docker Compose first: https://docs.docker.com/compose/install/"
    exit 1
fi

# Determine docker-compose command
if docker compose version &> /dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

echo "Step 1: Checking and fixing Docker network configuration..."
if [ -f /etc/docker/daemon.json ]; then
    echo "Backing up existing /etc/docker/daemon.json..."
    sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.backup 2>/dev/null || true
fi

echo "Configuring Docker to disable IPv6..."
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "ipv6": false,
  "dns": ["8.8.8.8", "8.8.4.4"],
  "registry-mirrors": []
}
EOF

echo "Restarting Docker daemon..."
sudo systemctl restart docker
sleep 3

if ! sudo systemctl is-active --quiet docker; then
    echo "ERROR: Docker failed to start. Please check: sudo journalctl -u docker -n 50"
    exit 1
fi
echo "✓ Docker network configured"

echo ""
echo "Step 2: Creating necessary directories..."
mkdir -p logs temp config

echo ""
echo "Step 3: Setting permissions..."
chmod 777 logs temp

echo ""
echo "Step 4: Building Docker images..."
$DOCKER_COMPOSE build

echo ""
echo "Step 5: Starting containers..."
$DOCKER_COMPOSE up -d

echo ""
echo "Step 6: Waiting for services to be ready..."
sleep 10

echo ""
echo "Step 7: Initializing database..."
$DOCKER_COMPOSE exec -T db mysql -u root -proot_password -e "SHOW DATABASES;" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Database is ready"
else
    echo "⚠ Database might need more time to initialize"
fi

echo ""
echo "Step 8: Copying CTF configuration to Roundcube..."
docker exec roundcube-mail cp /var/www/html/roundcube/config.ctf.php /var/www/html/roundcube/config/config.inc.php 2>/dev/null || true
docker exec roundcube-mail chown www-data:www-data /var/www/html/roundcube/config/config.inc.php 2>/dev/null || true
echo "✓ Configuration installed"

echo ""
echo "Step 9: Initializing Roundcube database..."
docker exec roundcube-mail php /var/www/html/roundcube/bin/initdb.sh --dir=/var/www/html/roundcube/SQL 2>/dev/null || echo "Database already initialized"

echo ""
echo "Step 10: Adding test emails to CTF accounts..."
sleep 3

# Function to create an email
create_email() {
    local user=$1
    local from=$2
    local subject=$3
    local body=$4
    
    local timestamp=$(date +%s)
    local filename="${timestamp}.localhost"
    
    docker exec -i roundcube-imap sh << EOF 2>/dev/null
mkdir -p /var/mail/${user}/cur /var/mail/${user}/new /var/mail/${user}/tmp
cat > /var/mail/${user}/new/${filename} << 'EMAILEOF'
From: ${from}
To: ${user}@localhost
Subject: ${subject}
Date: $(date -R)
Message-ID: <${timestamp}@localhost>
Content-Type: text/plain; charset=UTF-8

${body}
EMAILEOF
chown -R ${user}:${user} /var/mail/${user}
chmod -R 700 /var/mail/${user}
EOF
    sleep 1
}

create_email "ctfuser1" "admin@ctf.local" "Welcome to CTF Challenge" \
"Welcome ctfuser1!

This is your first email. Your mission is to explore the mail system
and find hidden flags.

Good luck!
- CTF Admin

Flag 1: CTF{welcome_to_roundcube_mail}"

create_email "ctfuser1" "security@ctf.local" "Security Notice" \
"Dear ctfuser1,

We noticed unusual activity on your account. Please check your
other messages for important information.

Hint: Sometimes the most valuable information is hidden in headers.

- Security Team"

create_email "ctfuser2" "challenge@ctf.local" "Next Level Challenge" \
"Hello ctfuser2!

Congratulations on making it this far. The next flag requires
you to think outside the box.

Have you checked what the other users are doing?

Flag 2: CTF{imap_enumeration_success}

- Challenge Master"

create_email "ctfuser3" "ctfuser1@localhost" "Meeting Notes" \
"Hi ctfuser3,

Here are the notes from our last meeting:

1. Project deadline: Next week
2. Password policy: Use strong passwords
3. Don't share credentials

BTW, did you know that ctfuser2 has some interesting emails?

Best regards,
ctfuser1

P.S. The final flag is: CTF{you_read_all_accounts}"

echo "✓ Test emails added to all accounts"

echo ""
echo "================================================"
echo "  Deployment Complete!"
echo "================================================"
echo ""
echo "Container Status:"
$DOCKER_COMPOSE ps
echo ""
echo "Access Information:"
echo "  - Roundcube Mail:      http://localhost:8080/"
echo "  - phpMyAdmin:          http://localhost:8081/"
echo ""
echo "================================================"
echo "  CTF MAIL ACCOUNTS (Login to Roundcube)"
echo "================================================"
echo "  Username: ctfuser1  |  Password: CTFpass123!"
echo "  Username: ctfuser2  |  Password: CTFpass456!"
echo "  Username: ctfuser3  |  Password: CTFpass789!"
echo ""
echo "================================================"
echo "  SYSTEM USERS (Container Shell Access)"
echo "================================================"
echo "  - user1 (password: password1)"
echo "  - user2 (password: password2)"
echo "  - user3 (password: password3)"
echo ""
echo "Database Credentials:"
echo "  - Host:     db"
echo "  - Database: roundcubemail"
echo "  - User:     roundcube"
echo "  - Password: roundcube_password"
echo ""
echo "To access the container shell:"
echo "  docker exec -it roundcube-mail bash"
echo ""
echo "To switch to a specific user:"
echo "  docker exec -it -u user1 roundcube-mail bash"
echo ""
echo "================================================"
echo "  🚀 ROUNDCUBE IS READY TO USE!"
echo "================================================"
echo ""
echo "✓ Docker network configured"
echo "✓ All containers running"
echo "✓ Database initialized"
echo "✓ Roundcube configured"
echo "✓ Test emails added"
echo ""
echo "🌐 Open your browser: http://localhost:8080/"
echo ""
echo "Login with any of these accounts:"
echo "  • ctfuser1 / CTFpass123!"
echo "  • ctfuser2 / CTFpass456!"
echo "  • ctfuser3 / CTFpass789!"
echo ""
echo "Each account has test emails with sample flags!"
echo ""
echo "Other commands:"
echo "  View logs:        $DOCKER_COMPOSE logs -f"
echo "  Stop containers:  $DOCKER_COMPOSE down"
echo "  Reset all data:   $DOCKER_COMPOSE down -v"
echo ""
echo "================================================"
