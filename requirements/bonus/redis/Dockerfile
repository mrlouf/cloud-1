FROM debian:bullseye

RUN apt update && \
    apt install -y redis-server && \
    rm -rf /var/lib/apt/lists/*

COPY ./tools/redis.sh .

RUN chmod +x redis.sh

EXPOSE 6379

ENTRYPOINT ["./redis.sh"]

CMD ["redis-server", "--protected-mode", "no"]