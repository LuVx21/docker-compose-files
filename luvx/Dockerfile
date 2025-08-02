# --build-arg CR=$ALI_CR_NS
ARG CR=${CR:-""}
ARG REGISTRY=${CR:+$CR/}
ARG VERSION=bookworm
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM ${REGISTRY}debian:${VERSION} AS base
ARG T=0
RUN set -eux; \
    pkg='ca-certificates'; \
    if [ $T -ge 1 ]; then pkg=$pkg' curl wget'; fi; \
    if [ $T -ge 2 ]; then pkg=$pkg' bzip2 unzip xz-utils bzip2'; fi; \
    if [ $T -ge 3 ]; then pkg=$pkg' git'; fi; \
    sed -i 's|deb.debian.org|mirrors.aliyun.com|g' /etc/apt/sources.list.d/debian.sources; \
    apt-get update && apt-get install -y --no-install-recommends $pkg; \
    rm -rf /var/lib/apt/lists/*
RUN dpkgArch="$(dpkg --print-architecture)"; \
    case "${dpkgArch##*-}" in \
        amd64) ARCH=x64 ARCH_V1=x64 ARCH_V2=amd64 ARCH_V3=amd64 ;; \
        arm64) ARCH=aarch64 ARCH_V1=arm64 ARCH_V2=aarch64 ARCH_V3=arm64 ;; \
        *) echo >&2 "不支持的架构: ${dpkgArch}"; exit 1 ;; \
    esac; \
    # 使用时先执行: export $(cat /env | xargs)
    echo "ARCH=$ARCH\nARCH_V1=$ARCH_V1\nARCH_V2=$ARCH_V2\nARCH_V3=$ARCH_V3" > /env

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM luvx/base:1 AS base-1-arch-amd64
ARG ARCH=x64 ARCH_V1=x64 ARCH_V2=amd64 ARCH_V3=amd64
FROM luvx/base:1 AS base-1-arch-arm64
ARG ARCH=aarch64 ARCH_V1=arm64 ARCH_V2=aarch64 ARCH_V3=arm64
FROM base-1-arch-$TARGETARCH AS base-1-arch

FROM luvx/base:2 AS base-2-arch-amd64
ARG ARCH=x64 ARCH_V1=x64 ARCH_V2=amd64 ARCH_V3=amd64
FROM luvx/base:2 AS base-2-arch-arm64
ARG ARCH=aarch64 ARCH_V1=arm64 ARCH_V2=aarch64 ARCH_V3=arm64
FROM base-2-arch-$TARGETARCH AS base-2-arch

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM base-1-arch AS oracle_jdk

ARG JAVA_VERSION='21'
ENV JAVA_HOME=/opt/install/java
ENV PATH=$JAVA_HOME/bin:$PATH

RUN mkdir -p $JAVA_HOME && wget -O - "https://download.oracle.com/java/${JAVA_VERSION}/latest/jdk-${JAVA_VERSION}_linux-${ARCH}_bin.tar.gz" | tar -zxvf - -C $JAVA_HOME --strip-components 1

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM base-1-arch AS graalvm_jdk

ARG JAVA_VERSION='21'
ENV JAVA_HOME=/opt/install/java
ENV PATH=$JAVA_HOME/bin:$PATH

RUN mkdir -p $JAVA_HOME && wget -O - "https://download.oracle.com/graalvm/${JAVA_VERSION}/latest/graalvm-jdk-${JAVA_VERSION}_linux-${ARCH}_bin.tar.gz" | tar -zxvf - -C $JAVA_HOME --strip-components 1

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# docker build --target mvnd -t luvx/mvnd:1.0.2-23 --platform linux/amd64 --build-arg MVND_VERSION=1.0.2 .
FROM luvx/base:1 AS mvnd_downloader

ARG MVND_VERSION='1.0.2' PLATFORM=linux ARCH=amd64
RUN curl -fSL -o maven-mvnd.tar.gz https://github.com/apache/maven-mvnd/releases/download/${MVND_VERSION}/maven-mvnd-${MVND_VERSION}-${PLATFORM}-${ARCH}.tar.gz

FROM ${REGISTRY}eclipse-temurin:23 AS mvnd

ENV MVND_HOME=/opt/install/mvnd
ENV PATH=$MVND_HOME/bin:$MVND_HOME/mvn/bin:$PATH

COPY --from=mvnd_downloader maven-mvnd.tar.gz .
RUN mkdir -p $MVND_HOME && tar --strip-components=1 -xzf maven-mvnd.tar.gz -C $MVND_HOME \
    && rm -rf maven-mvnd.tar.gz
VOLUME /root/.m2

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM ${REGISTRY}buildpack-deps:curl AS iredis_downloader
RUN wget https://github.com/laixintao/iredis/releases/latest/download/iredis.tar.gz \
 && tar -xzf iredis.tar.gz

FROM ${REGISTRY}debian:${VERSION}-slim AS iredis
COPY --from=iredis_downloader iredis /usr/bin
COPY --from=iredis_downloader lib /usr/bin/lib
ENTRYPOINT [ "iredis" ]

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM base-1-arch AS vscode_downloader

RUN wget -O vscode_cli.tar.gz "https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-${ARCH_V1}" \
    && tar -zxvf vscode_cli.tar.gz

FROM luvx/base:0 AS vscode
COPY --from=vscode_downloader code /usr/bin
VOLUME ["/root/.vscode", "/root/.vscode-server"]
EXPOSE 8000
ENTRYPOINT ["code"]

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM ${REGISTRY}buildpack-deps:${VERSION} AS upx_downloader
ARG UPX_VERSION=5.0.1
RUN <<EOT
    #!/bin/bash
    dpkgArch="$(dpkg --print-architecture)"
    case "${dpkgArch##*-}" in \
        amd64) upxArch='amd64' ;;
        arm64) upxArch='arm64' ;;
        *) echo >&2 "不支持的架构: ${dpkgArch}"; exit 1 ;;
    esac
    # [[ $dpkgArch == 'arm64' ]] && upxArch="arm64" || upxArch="amd64"
    wget -O upx.tar.xz "https://github.com/upx/upx/releases/download/v${UPX_VERSION}/upx-${UPX_VERSION}-${upxArch}_linux.tar.xz"
    tar -Jxvf upx.tar.xz --strip-components 1
EOT

FROM ${REGISTRY}debian:${VERSION}-slim AS upx
COPY --from=upx_downloader upx /usr/bin

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM base-2-arch AS duckdb_downloader
RUN curl -L -o duckdb_cli.zip "https://github.com/duckdb/duckdb/releases/latest/download/duckdb_cli-linux-${ARCH_V3}.zip" \
    && unzip duckdb_cli.zip && rm duckdb_cli.zip

FROM ${REGISTRY}debian:${VERSION}-slim AS duckdb
COPY --from=duckdb_downloader duckdb .
ENTRYPOINT [ "./duckdb" ]

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM ${REGISTRY}buildpack-deps:${VERSION} AS ldb_builder
ARG TAG
RUN if [ -z $TAG ]; then TAG=$(git ls-remote --tags https://github.com/facebook/rocksdb | grep -v '\^{}' | grep -o 'refs/tags/[^{}]*' | sort -V | tail -n1 | sed 's|refs/tags/||'); fi; \
    git clone -b $TAG --depth=1 https://github.com/facebook/rocksdb; \
    cd rocksdb && make -j$(nproc) DEBUG_LEVEL=0 USE_SNAPPY=1 USE_LZ4=1 USE_ZSTD=1 USE_ZLIB=1 ldb sst_dump

FROM ${REGISTRY}debian:${VERSION}-slim AS ldb
RUN apt update && apt install -y libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev
COPY --from=ldb_builder /rocksdb/ldb /usr/bin
COPY --from=ldb_builder /rocksdb/sst_dump /usr/bin

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM ${REGISTRY}maven:3-eclipse-temurin-8 AS rocketmq-dashboard-builder
ARG RD_VERSION='2.1.0'

RUN apt-get update && apt-get install -y git
RUN git clone --depth=1 -b rocketmq-dashboard-${RD_VERSION} https://github.com/apache/rocketmq-dashboard && \
    cd rocketmq-dashboard && mvn clean package -Dmaven.test.skip=true && \
    mv target/rocketmq-dashboard-*.jar /rocketmq-dashboard.jar

FROM ${REGISTRY}eclipse-temurin:8-jre AS rocketmq-dashboard

WORKDIR /app
COPY --from=rocketmq-dashboard-builder rocketmq-dashboard.jar .
ENV JAVA_OPTS=""
ENTRYPOINT [ "sh", "-c", "java $JAVA_OPTS -jar ./rocketmq-dashboard.jar" ]

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM ${REGISTRY}golang:1.24-${VERSION} AS go-installer

ARG GO_INSTALL_URL
COPY --from=luvx/upx:latest --link /usr/bin/upx /usr/bin/upx
SHELL ["/bin/bash", "-c"]
RUN <<EOT
    #!/bin/bash
    for URL in $(echo "$GO_INSTALL_URL" | tr ',' ' '); do
        go install -ldflags="-w -s" ${URL}
    done
    upx -9 $(go env GOPATH)/bin/*
EOT

FROM ${REGISTRY}debian:${VERSION}-slim AS go-runner
COPY --from=go-installer /go/bin/* /usr/bin

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM ${REGISTRY}python:3-slim-${VERSION} AS python-runner
ARG PACKAGES
RUN pip3 config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple; \
    for package in $(echo "$PACKAGES" | tr ',' ' '); do pip3 install --no-cache-dir ${package}; done; \
    pip3 cache purge && rm -fr $(pip3 cache dir) && rm -fr /root/.cache

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM ${REGISTRY}debian:${VERSION}-slim AS debian-runner
ARG PACKAGE
RUN apt-get update && apt-get install -y --no-install-recommends ${PACKAGE}; \
    rm -rf /var/lib/apt/lists/*