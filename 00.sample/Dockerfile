ARG CR=${CR:-""}
ARG REGISTRY=${CR}${CR:+/}
ARG VERSION=3.19

FROM alpine:${VERSION} AS base-0

RUN echo "https://mirrors.aliyun.com/alpine/v${VERSION}/main/" > /etc/apk/repositories \
    && echo "https://mirrors.aliyun.com/alpine/v${VERSION}/community/" >> /etc/apk/repositories

# docker buildx build --build-arg CR=$ALI_CR_NS --build-arg VERSION=3.21 --platform=linux/amd64,linux/arm64 . --push \
# -t luvx/alpine:3 -t $ALI_CR_NS/alpine:3 -t $TX_CR_NS/alpine:3 \
# -t luvx/alpine:3.21 -t $ALI_CR_NS/alpine:3.21 -t $TX_CR_NS/alpine:3.21 \
# -t luvx/alpine:latest -t $ALI_CR_NS/alpine:latest -t $TX_CR_NS/alpine:latest
