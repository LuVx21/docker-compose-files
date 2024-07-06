FROM alpine:3.19

RUN echo "https://mirrors.aliyun.com/alpine/v3.19/main/" > /etc/apk/repositories \
    && echo "https://mirrors.aliyun.com/alpine/v3.19/community/" >> /etc/apk/repositories \
    && apk update && apk add --no-cache bash mysql-client
