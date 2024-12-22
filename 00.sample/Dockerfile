ARG CR=${CR:-""}
ARG REGISTRY=${CR}${CR:+/}
ARG VERSION=3.19

FROM ${REGISTRY}alpine:${VERSION} AS base-0

RUN echo "https://mirrors.aliyun.com/alpine/v${VERSION}/main/" > /etc/apk/repositories \
    && echo "https://mirrors.aliyun.com/alpine/v${VERSION}/community/" >> /etc/apk/repositories

# docker build -t luvx/alpine . --build-arg CR=$ALI_CR_NS