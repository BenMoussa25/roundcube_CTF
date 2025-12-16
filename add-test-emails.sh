#!/bin/bash

# Script to add test emails to CTF user mailboxes

echo "================================================"
echo "  Add Test Emails to CTF Users"
echo "================================================"
echo ""

# Function to create an email
create_email() {
    local user=$1
    local from=$2
    local subject=$3
    local body=$4
    
    local timestamp=$(date +%s)
    local filename="${timestamp}.localhost"
    
    docker exec -i roundcube-imap sh << EOF
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
    
    if [ $? -eq 0 ]; then
        echo "✓ Email added to ${user}: ${subject}"
    else
        echo "✗ Failed to add email to ${user}"
    fi
}

# Add sample emails
echo "Adding sample emails to CTF users..."
echo ""

# Email to ctfuser1
create_email "ctfuser1" "admin@ctf.local" "Welcome to CTF Challenge" \
"Welcome ctfuser1!

This is your first email. Your mission is to explore the mail system
and find hidden flags.

Good luck!
- CTF Admin

Flag 1: CTF{welcome_to_roundcube_mail}"

# Email to ctfuser1 with hint
create_email "ctfuser1" "security@ctf.local" "Security Notice" \
"Dear ctfuser1,

We noticed unusual activity on your account. Please check your
other messages for important information.

Hint: Sometimes the most valuable information is hidden in headers.

- Security Team"

# Email to ctfuser2
create_email "ctfuser2" "challenge@ctf.local" "Next Level Challenge" \
"Hello ctfuser2!

Congratulations on making it this far. The next flag requires
you to think outside the box.

Have you checked what the other users are doing?

Flag 2: CTF{imap_enumeration_success}

- Challenge Master"

# Email to ctfuser3
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

echo ""
echo "================================================"
echo "  Emails Added Successfully!"
echo "================================================"
echo ""
echo "Login to Roundcube at http://localhost:8080/"
echo ""
echo "Test the following accounts:"
echo "  - ctfuser1 : CTFpass123!"
echo "  - ctfuser2 : CTFpass456!"
echo "  - ctfuser3 : CTFpass789!"
echo ""
echo "To add custom emails, edit this script or use:"
echo "  docker exec -it roundcube-imap ash"
echo ""
