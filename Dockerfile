FROM ubuntu:22.04

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive
ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_GROUP=www-data
ENV APACHE_LOG_DIR=/var/log/apache2
ENV APACHE_LOCK_DIR=/var/lock/apache2
ENV APACHE_PID_FILE=/var/run/apache2.pid

# Install dependencies
RUN apt-get update && apt-get install -y \
    apache2 \
    php8.1 \
    php8.1-cli \
    php8.1-common \
    php8.1-curl \
    php8.1-gd \
    php8.1-intl \
    php8.1-ldap \
    php8.1-mbstring \
    php8.1-mysql \
    php8.1-pgsql \
    php8.1-sqlite3 \
    php8.1-xml \
    php8.1-zip \
    php8.1-imagick \
    libapache2-mod-php8.1 \
    curl \
    wget \
    unzip \
    vim \
    nano \
    sudo \
    git \
    composer \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache modules
RUN a2enmod rewrite headers deflate expires ssl

# Create 3 system users
RUN useradd -m -s /bin/bash -G www-data user1 && \
    echo "user1:password1" | chpasswd && \
    useradd -m -s /bin/bash -G www-data user2 && \
    echo "user2:password2" | chpasswd && \
    useradd -m -s /bin/bash -G www-data user3 && \
    echo "user3:password3" | chpasswd && \
    echo "user1 ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "user2 ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "user3 ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set up Roundcube directory
WORKDIR /var/www/html/roundcube

# Copy Roundcube files
COPY . /var/www/html/roundcube/

# Configure PHP
RUN sed -i 's/memory_limit = .*/memory_limit = 256M/' /etc/php/8.1/apache2/php.ini && \
    sed -i 's/upload_max_filesize = .*/upload_max_filesize = 50M/' /etc/php/8.1/apache2/php.ini && \
    sed -i 's/post_max_size = .*/post_max_size = 50M/' /etc/php/8.1/apache2/php.ini && \
    sed -i 's/max_execution_time = .*/max_execution_time = 300/' /etc/php/8.1/apache2/php.ini && \
    echo "date.timezone = UTC" >> /etc/php/8.1/apache2/php.ini

# Install Composer dependencies
RUN if [ -f composer.json-dist ]; then \
        cp composer.json-dist composer.json; \
    fi && \
    composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader || true

# Install JavaScript dependencies
RUN if [ -f bin/install-jsdeps.sh ]; then \
        bash bin/install-jsdeps.sh || true; \
    fi

# Install node-less and compile CSS for elastic skin
RUN apt-get update -qq && \
    apt-get install -y -qq node-less && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Compile CSS files for Elastic skin
RUN cd skins/elastic && \
    lessc styles/styles.less styles/styles.css && \
    lessc styles/print.less styles/print.css && \
    lessc styles/embed.less styles/embed.css

# Set proper permissions
RUN mkdir -p /var/www/html/roundcube/temp /var/www/html/roundcube/logs && \
    chown -R www-data:www-data /var/www/html/roundcube && \
    chmod -R 775 /var/www/html/roundcube/temp /var/www/html/roundcube/logs && \
    chmod -R 755 /var/www/html/roundcube

# Set ServerName to suppress warning
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Configure Apache
RUN echo '<VirtualHost *:80>\n\
    ServerName localhost\n\
    ServerAdmin webmaster@localhost\n\
    DocumentRoot /var/www/html/roundcube\n\
    \n\
    <Directory /var/www/html/roundcube>\n\
        Options +FollowSymLinks\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
    \n\
    <Directory /var/www/html/roundcube/config>\n\
        Require all denied\n\
    </Directory>\n\
    \n\
    <Directory /var/www/html/roundcube/temp>\n\
        Require all denied\n\
    </Directory>\n\
    \n\
    <Directory /var/www/html/roundcube/logs>\n\
        Require all denied\n\
    </Directory>\n\
    \n\
    ErrorLog ${APACHE_LOG_DIR}/error.log\n\
    CustomLog ${APACHE_LOG_DIR}/access.log combined\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Expose port 80
EXPOSE 80

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Start Apache
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["apache2-foreground"]
