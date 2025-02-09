ARG CR=${CR:-""}
ARG REGISTRY=${CR:+$CR/}
ARG VERSION=3.21

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM alpine:${VERSION} AS alpine
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM luvx/alpine:latest AS alpine-arch-amd64
ARG ARCH=x64 ARCH_V1=x64 ARCH_V2=amd64 ARCH_V3=amd64
FROM luvx/alpine:latest AS alpine-arch-arm64
ARG ARCH=aarch64 ARCH_V1=arm64 ARCH_V2=aarch64 ARCH_V3=arm64
FROM alpine-arch-$TARGETARCH AS alpine-arch

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM alpine-arch AS vscode_downloader

RUN wget -O vscode_cli.tar.gz "https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-${ARCH_V1}" \
    && tar -zxvf vscode_cli.tar.gz

FROM luvx/alpine:latest AS vscode
COPY --from=vscode_downloader code /usr/bin
RUN apk add --update --no-cache libstdc++ # curl procps gcompat
VOLUME ["/root/.vscode", "/root/.vscode-server"]
EXPOSE 8000
ENTRYPOINT ["code"]

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM alpine-arch AS upx_downloader
ARG UPX_VERSION=4.2.4
RUN <<EOT
    #!/bin/sh
    dpkgArch="$(arch --print-architecture)"
    case "${dpkgArch##*-}" in \
        x86_64) upxArch='amd64' ;;
        aarch64) upxArch='arm64' ;;
        *) echo >&2 "不支持的架构: ${dpkgArch}"; exit 1 ;;
    esac
    wget -O upx.tar.xz "https://github.com/upx/upx/releases/download/v${UPX_VERSION}/upx-${UPX_VERSION}-${upxArch}_linux.tar.xz"
    tar -Jxvf upx.tar.xz --strip-components 1
EOT

FROM luvx/alpine:latest AS upx
COPY --from=upx_downloader upx /usr/bin

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM ${REGISTRY}golang:1.24-alpine AS go-installer

ARG GO_INSTALL_URL
COPY --from=luvx/upx:latest-alpine --link /usr/bin/upx /usr/bin/upx
RUN <<EOT
    #!/bin/sh
    for URL in $(echo "$GO_INSTALL_URL" | tr ',' ' '); do
        go install -ldflags="-w -s" ${URL}
    done
    upx -9 $(go env GOPATH)/bin/*
EOT

FROM ${REGISTRY}alpine:${VERSION} AS go-runner
COPY --from=go-installer /go/bin/* /usr/bin

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM ${REGISTRY}python:3-alpine AS python-runner
ARG PACKAGES
RUN pip3 config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple; \
    for package in $(echo "$PACKAGES" | tr ',' ' '); do pip3 install --no-cache-dir ${package}; done; \
    pip3 cache purge && rm -fr $(pip3 cache dir) && rm -fr /root/.cache

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM luvx/alpine:latest AS alpine-runner
ARG PACKAGE
RUN apk add --update --no-cache ${PACKAGE} && rm -fr /var/cache/apk/*