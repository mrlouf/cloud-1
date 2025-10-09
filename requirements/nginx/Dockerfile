FROM debian:bullseye

RUN apt -y update && apt -y upgrade && apt install -y nginx && apt install -y openssl

RUN mkdir -p /var/www 
RUN chmod +x /var/www/
COPY ./tools/nginx_start.sh /var/www/
COPY ./conf/nginx.conf /etc/nginx/sites-enabled/default

RUN chmod +x /var/www/nginx_start.sh

EXPOSE 443

ENTRYPOINT [ "/var/www/nginx_start.sh" ]

CMD ["nginx", "-g", "daemon off;"]