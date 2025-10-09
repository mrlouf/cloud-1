FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y vsftpd net-tools && \
    rm -rf /var/lib/apt/lists/*

COPY --chmod=755 ./tools/ftp_start.sh /usr/local/bin/ftp_start.sh

EXPOSE 21

ENTRYPOINT ["/usr/local/bin/ftp_start.sh"]

CMD ["vsftpd", "/etc/vsftpd.conf"]