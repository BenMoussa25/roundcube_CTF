#!/bin/bash
set -e

echo "Starting Roundcube Mail Docker Container..."
echo "========================================"

# Display CTF user information
echo ""
echo "CTF Mail Accounts (Use these to login to Roundcube):"
echo "  - Username: ctfuser1  |  Password: CTFpass123!"
echo "  - Username: ctfuser2  |  Password: CTFpass456!"
echo "  - Username: ctfuser3  |  Password: CTFpass789!"
echo ""
echo "System Users (for container shell access):"
echo "  - user1 (password: password1)"
echo "  - user2 (password: password2)"
echo "  - user3 (password: password3)"
echo ""

# Ensure proper permissions
chown -R www-data:www-data /var/www/html/roundcube/temp /var/www/html/roundcube/logs
chmod -R 775 /var/www/html/roundcube/temp /var/www/html/roundcube/logs

# Check if config file exists, if not use CTF config
if [ ! -f /var/www/html/roundcube/config/config.inc.php ]; then
    echo "No config found, using CTF configuration..."
    if [ -f /var/www/html/roundcube/config.ctf.php ]; then
        cp /var/www/html/roundcube/config.ctf.php /var/www/html/roundcube/config/config.inc.php
        chown www-data:www-data /var/www/html/roundcube/config/config.inc.php
        echo "✓ CTF configuration installed"
    fi
fi

echo ""
echo "Roundcube installation location: /var/www/html/roundcube"
echo "Apache is starting..."
echo "========================================"
echo ""

# Start Apache in foreground
exec apache2ctl -D FOREGROUND
