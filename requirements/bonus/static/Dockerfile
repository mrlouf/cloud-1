FROM debian:bullseye

RUN apt -y update && apt -y upgrade && apt install -y nginx && apt install -y openssl

RUN mkdir -p /usr/share/nginx/html
RUN chmod +x /usr/share/nginx/html

COPY ./tools/nginx_start.sh /usr/local/bin/
COPY ./conf/nginx.conf /etc/nginx/sites-enabled/default
COPY ./content /usr/share/nginx/html
RUN chmod +x /usr/local/bin/nginx_start.sh

EXPOSE 8443

ENTRYPOINT [ "/usr/local/bin/nginx_start.sh" ]
CMD ["nginx", "-g", "daemon off;"]
