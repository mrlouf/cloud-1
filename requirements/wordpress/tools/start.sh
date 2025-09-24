#!/bin/bash
sleep 5
set -e  # Exit on error

# Define the path to WordPress installation
# WORDPRESS_PATH="/var/www/html"

# Download WordPress if not already installed
if [ ! -f "./wp-config.php" ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root

    echo "Configuring wp-config.php..."

      # Generate wp-config.php with the given DB details
    wp config create \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_USER_PWD" \
        --dbhost="$DB_HOSTNAME" \
        --allow-root

    # Install WordPress with given site details
    wp core install \
        --url="$DOMAIN_NAME" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN" \
        --admin_password="$WP_ADMIN_PWD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root

    # Create an additional user
    wp user create "$WP_USER" "$WP_USER_EMAIL" \
        --role=contributor \
        --user_pass="$WP_USER_PWD" \
        --allow-root

    # Install and activate a theme
    wp theme install twentytwentythree --activate --allow-root
    
    # Install and configurate redis 
	  wp config set WP_REDIS_HOST redis --allow-root
  	wp config set WP_REDIS_PORT 6379 --raw --allow-root
 	  wp config set WP_REDIS_PREFIX "${DOMAIN_NAME}" --allow-root
 	  wp config set WP_REDIS_CLIENT phpredis --allow-root
	  wp plugin install redis-cache --activate --allow-root
    wp plugin update --all --allow-root
	  wp redis enable --allow-root

    echo "WordPress installed successfully!"
else
  echo "WordPress is already installed, skipping download and installation."
fi

# Run the PHP-FPM process
echo "Starting PHP-FPM..."
/usr/sbin/php-fpm7.4 -F