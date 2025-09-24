FROM debian:bullseye

USER root

RUN apt -y update && apt -y upgrade && apt install -y mariadb-server

COPY ./conf/mdb.cnf /etc/mysql/mariadb.conf.d/
COPY ./tools/mdb_start.sh /usr/local/bin/

RUN chmod a+x /usr/local/bin/mdb_start.sh
RUN mkdir -p /var/run/mysqld && chown -R mysql:mysql /var/run/mysqld && chmod 755 /var/run/mysqld

EXPOSE 3306

ENTRYPOINT [ "usr/local/bin/mdb_start.sh" ]