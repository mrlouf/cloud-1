#!/bin/bash

# Remove service start command, as it’s not needed
# service mariadb start  # Remove this line

# Initialize MariaDB if the database directory is empty
if [ ! -d /var/lib/mysql/${DB_NAME} ]; then
    echo "Building Database ${DB_NAME}"
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Start the MariaDB service in the background
    mysqld_safe --datadir=/var/lib/mysql &
    sleep 5  # Give some time for the server to start

    mysql -u root -p${DB_HOST_PWD} -e "CREATE DATABASE $DB_NAME;"
    mysql -u root -p${DB_HOST_PWD} -e "CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_USER_PWD';"
    mysql -u root -p${DB_HOST_PWD} -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';"
    mysql -u root -p${DB_HOST_PWD} -e "FLUSH PRIVILEGES;"
    echo "Database ${DB_NAME} is built."
fi

# Now start mysqld
mysqld_safe --datadir=/var/lib/mysql

