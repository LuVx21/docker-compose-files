# --build-arg CR=$ALI_CR_NS
ARG CR=${CR:-""}
ARG REGISTRY=${CR}${CR:+/}
ARG VERSION=bookworm
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM ${REGISTRY}debian:${VERSION} AS base-0
ARG T=0
RUN set -eux; \
    pkg='ca-certificates'; \
    if [ $T -ge 1 ]; then pkg=$pkg' curl wget'; fi; \
    if [ $T -ge 2 ]; then pkg=$pkg' bzip2 unzip xz-utils bzip2'; fi; \
    if [ $T -ge 3 ]; then pkg=$pkg' git'; fi; \
    sed -i 's|deb.debian.org|mirrors.aliyun.com|g' /etc/apt/sources.list.d/debian.sources; \
    apt-get update && apt-get install -y --no-install-recommends $pkg; \
    rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM luvx/base-0:${VERSION} AS base-1
RUN set -eux; \
    apt-get update && apt-get install -y --no-install-recommends curl wget; \
    rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM luvx/base-1:${VERSION} AS base-2
RUN set -eux; \
    apt-get update && apt-get install -y --no-install-recommends bzip2 unzip xz-utils bzip2; \
    rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM luvx/base-1:${VERSION} AS base-1-arch-amd64
ARG ARCH=x64 ARCH_V1=x64 ARCH_V2=amd64
FROM luvx/base-1:${VERSION} AS base-1-arch-arm64
ARG ARCH=aarch64 ARCH_V1=arm64 ARCH_V2=aarch64
FROM base-1-arch-$TARGETARCH AS base-1-arch

FROM luvx/base-2:${VERSION} AS base-2-arch-amd64
ARG ARCH=x64 ARCH_V1=x64 ARCH_V2=amd64
FROM luvx/base-2:${VERSION} AS base-2-arch-arm64
ARG ARCH=aarch64 ARCH_V1=arm64 ARCH_V2=aarch64
FROM base-2-arch-$TARGETARCH AS base-2-arch

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM luvx/base-2:${VERSION} AS ops

RUN apt update && apt install -y zsh curl wget tree vim git
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone --depth=1 https://github.com/zsh-users/zsh-completions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions && \
    chsh -s /usr/bin/zsh
SHELL ["/usr/bin/zsh", "-c"]
RUN source ~/.zshrc && omz plugin enable git docker docker-compose history-substring-search z zsh-autosuggestions zsh-completions zsh-syntax-highlighting

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM base-1-arch AS oracle_jdk

ARG JAVA_VERSION='23'
ENV JAVA_HOME=/opt/install/java
ENV PATH=$JAVA_HOME/bin:$PATH

RUN mkdir -p $JAVA_HOME && wget -O - "https://download.oracle.com/java/${JAVA_VERSION}/latest/jdk-${JAVA_VERSION}_linux-${ARCH}_bin.tar.gz" | tar -zxvf - -C $JAVA_HOME --strip-components 1

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM base-1-arch AS graalvm_jdk

ARG JAVA_VERSION='23'
ENV JAVA_HOME=/opt/install/java
ENV PATH=$JAVA_HOME/bin:$PATH

RUN mkdir -p $JAVA_HOME && wget -O - "https://download.oracle.com/graalvm/${JAVA_VERSION}/latest/graalvm-jdk-${JAVA_VERSION}_linux-${ARCH}_bin.tar.gz" | tar -zxvf - -C $JAVA_HOME --strip-components 1

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# docker build --target mvnd -t luvx/mvnd:1.0.2-23 --platform linux/amd64 --build-arg MVND_VERSION=1.0.2 .
FROM luvx/base-1:${VERSION} AS mvnd_downloader

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
FROM base-1-arch AS vscode_downloader

RUN wget -O vscode_cli.tar.gz "https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-${ARCH_V1}" \
    && tar -zxvf vscode_cli.tar.gz

FROM luvx/base-0:${VERSION} AS vscode
COPY --from=vscode_downloader code /usr/bin
VOLUME ["/root/.vscode", "/root/.vscode-server"]
EXPOSE 8000
ENTRYPOINT ["code"]

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM ${REGISTRY}buildpack-deps:${VERSION} AS upx_downloader
ARG UPX_VERSION=4.2.4
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

FROM ${REGISTRY}debian:${VERSION} AS upx
COPY --from=upx_downloader upx /usr/bin

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM base-2-arch AS duckdb_downloader
RUN curl -L -o duckdb_cli.zip "https://github.com/duckdb/duckdb/releases/latest/download/duckdb_cli-linux-${ARCH_V2}.zip" \
    && unzip duckdb_cli.zip && rm duckdb_cli.zip

FROM ${REGISTRY}debian:${VERSION} AS duckdb
COPY --from=duckdb_downloader duckdb .
ENTRYPOINT [ "./duckdb" ]

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM ${REGISTRY}maven:3-eclipse-temurin-8 AS rocketmq-dashboard-builder
ARG RD_VERSION='2.0.0'

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
FROM ${REGISTRY}golang:1.23-${VERSION} AS go-installer

ARG GO_INSTALL_URL
COPY --from=luvx/upx:latest --link /usr/bin/upx /usr/bin/upx
SHELL ["/bin/bash", "-c"]
RUN <<EOT
    #!/bin/bash
    for URL in ${GO_INSTALL_URL//,/ }; do
        go install -ldflags="-w -s" ${URL}
    done
    upx -9 $(go env GOPATH)/bin/*
EOT

FROM ${REGISTRY}debian:${VERSION} AS go-runner

COPY --from=go-installer /go/bin/* /usr/local/bin

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
