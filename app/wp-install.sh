#!/bin/bash

export WP_CLI_PHP_ARGS="-d memory_limit=512M"

if ! command -v wp &> /dev/null; then
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    php -d memory_limit=512M wp-cli.phar --info
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

# Wait for the database service to be ready
until php -r "mysqli_connect(getenv('MARIADB_HOSTNAME'), getenv('MARIADB_USER'), getenv('MARIADB_PASSWORD'), getenv('MARIADB_DATABASE'));" 2>/dev/null; do
    echo 'Waiting for database...'
    sleep 2
done

if [ -f /var/www/html/wp-config.php ]; then
    echo "WordPress already exists. Skipping installation."
else
    
    cd /var/www/html
    php -d memory_limit=512M /usr/local/bin/wp core download --allow-root

    # Generate wp-config.php
    php -d memory_limit=512M /usr/local/bin/wp config create \
        --dbname=$MARIADB_DATABASE \
        --dbuser=$MARIADB_USER \
        --dbpass=$MARIADB_PASSWORD \
        --dbhost=$MARIADB_HOSTNAME \
        --allow-root

    php -d memory_limit=512M /usr/local/bin/wp core install \
        --url=$DOMAIN_NAME \
        --title="$WORDPRESS_TITLE" \
        --admin_user=$WORDPRESS_ADMIN \
        --admin_password=$WORDPRESS_ADMIN_PASS \
        --admin_email=$WORDPRESS_ADMIN_MAIL \
        --skip-email \
        --allow-root \

    wp user create $WORDPRESS_USER $WORDPRESS_MAIL \
        --role=contributor \
        --user_pass=$WORDPRESS_USER_PASS \
        --allow-root \

    wp theme install twentytwentyfour --activate --allow-root

    # Import the image and get its attachment ID
    IMAGE_PATH="/var/www/html/cloud.jpg"
    IMAGE_ID=$(wp media import "$IMAGE_PATH" --title="Cloud Photo" --porcelain --allow-root)
    # Get the image URL
    IMAGE_URL=$(wp post get $IMAGE_ID --field=guid --allow-root)

    wp post delete $(wp post list --post_type=page --format=ids --allow-root) --force --allow-root
    FRONT_PAGE_ID=$(wp post list --post_type=page --post_status=publish --field=ID --title="Welcome to the cloud!" --allow-root)

    if [ -z "$FRONT_PAGE_ID" ]; then
        FRONT_PAGE_ID=$(wp post create --post_title="Welcome to the cloud!" --post_type="page" --post_status="publish" --allow-root | grep -oP '\d+')
        
        wp post update $FRONT_PAGE_ID --post_content="
        <div style=\"text-align: center; padding: 20px;\">
            <a href=\"https://$DOMAIN_NAME/wp-admin\" style=\"background-color: #0073aa; color: white; padding: 15px 32px; line-height: 0px; vertical-align: middle; text-align: center; text-decoration: none; display: inline-block; margin: 4px 2px; cursor: pointer; border-radius: 16px;\">
                Go to WordPress Dashboard
            </a>
            <p>If you can read this, it means that nzhuzhle & I succeeded in automating the deployment of this WordPress instance.</p>
            <p>Please take a moment to appreciate the beauty of clouds.</p>
            <img src=\"$IMAGE_URL\" alt=\"Cloud Photo\" style=\"max-width:100%;height:auto;\">
            <a href=\"#\" onclick=\"window.location.href=window.location.origin+'/adminer/';\" style=\"background-color: #FF0000; color: white; padding: 15px 32px; line-height: 0px; vertical-align: middle; text-align: center; text-decoration: none; display: inline-block; margin: 4px 2px; cursor: pointer; border-radius: 16px;\">
                Go to Adminer to check the database
            </a>
        </div>" --allow-root

    fi

    wp option update page_on_front $FRONT_PAGE_ID --allow-root
    wp option update show_on_front 'page' --allow-root
    
fi

# Start PHP-FPM in the foreground for proper container behavior
exec /usr/local/sbin/php-fpm -F