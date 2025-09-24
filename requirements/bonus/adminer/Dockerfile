FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y wget php7.4 php7.4-mysqli curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

RUN wget "http://www.adminer.org/latest.php" -O /var/www/html/adminer.php
RUN chown -R www-data:www-data /var/www/html/adminer.php
RUN chmod 755 /var/www/html/adminer.php

EXPOSE 8080

CMD ["php", "-S", "0.0.0.0:8080", "/var/www/html/adminer.php"]