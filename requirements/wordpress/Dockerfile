FROM debian:bullseye

# Install PHP-FPM and required extensions
RUN apt update && \
    apt install -y \
        php7.4 \
        php7.4-fpm \
        php7.4-mysqli \
        curl \
        vim \
        iputils-ping \
        php-redis \
        mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Verify PHP and PHP-FPM installation
RUN php -v && php-fpm7.4 -v

# Copy PHP-FPM configuration
COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/ 

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Create PHP run directory
RUN mkdir -p /run/php && \
    chmod 755 /run/php

# Copy and set permissions for the start script
COPY ./tools/start.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/start.sh

# Set working directory
WORKDIR /var/www/html

# Expose PHP-FPM port
EXPOSE 9000

# Set entrypoint to the start script
ENTRYPOINT [ "/usr/local/bin/start.sh" ]
