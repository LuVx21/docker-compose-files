ARG VERSION=bookworm
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM debian:${VERSION} AS base-0
RUN set -eux; \
    apt-get update && apt-get install -y --no-install-recommends ca-certificates; \
    rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM luvx/base-0:${VERSION} AS base-1
RUN set -eux; \
    apt-get update && apt-get install -y --no-install-recommends curl wget; \
    rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM luvx/base-1:${VERSION} AS base-2
RUN set -eux; \
    apt-get update && apt-get install -y --no-install-recommends git bzip2 unzip; \
    rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM luvx/base-1:${VERSION} AS base0
FROM base0 AS base-amd64
ARG ARCH=x64
ARG ARCH_SHORT=x64
FROM base0 AS base-arm64
ARG ARCH=aarch64
ARG ARCH_SHORT=arm64

FROM base-$TARGETARCH AS base

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM luvx/base-2:${VERSION} AS ops

RUN apt update && apt install -y zsh curl wget tree vim git
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM base AS oracle_jdk

ARG JAVA_VERSION='23'
ENV JAVA_HOME=/opt/install/java
ENV PATH=$JAVA_HOME/bin:$PATH

RUN mkdir -p $JAVA_HOME && wget -O - "https://download.oracle.com/java/${JAVA_VERSION}/latest/jdk-${JAVA_VERSION}_linux-${ARCH}_bin.tar.gz" | tar -zxvf - -C $JAVA_HOME --strip-components 1

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM base AS graalvm_jdk

ARG JAVA_VERSION='23'
ENV JAVA_HOME=/opt/install/java
ENV PATH=$JAVA_HOME/bin:$PATH

RUN mkdir -p $JAVA_HOME && wget -O - "https://download.oracle.com/graalvm/${JAVA_VERSION}/latest/graalvm-jdk-${JAVA_VERSION}_linux-${ARCH}_bin.tar.gz" | tar -zxvf - -C $JAVA_HOME --strip-components 1

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# docker build --target mvnd -t luvx/mvnd:1.0.2-23 --platform linux/amd64 --build-arg MVND_VERSION=1.0.2 .
FROM base0 AS mvnd_downloader

ARG MVND_VERSION='1.0.2' PLATFORM=linux ARCH=amd64
RUN curl -fSL -o maven-mvnd.tar.gz https://github.com/apache/maven-mvnd/releases/download/${MVND_VERSION}/maven-mvnd-${MVND_VERSION}-${PLATFORM}-${ARCH}.tar.gz

FROM eclipse-temurin:23 AS mvnd

ENV MVND_HOME=/opt/install/mvnd
ENV PATH=$MVND_HOME/bin:$MVND_HOME/mvn/bin:$PATH

COPY --from=mvnd_downloader maven-mvnd.tar.gz .
RUN mkdir -p $MVND_HOME && tar --strip-components=1 -xzf maven-mvnd.tar.gz -C $MVND_HOME \
    && rm -rf maven-mvnd.tar.gz

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM base AS vscode_downloader

RUN wget -O vscode_cli.tar.gz "https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-${ARCH_SHORT}" \
    && tar -zxvf vscode_cli.tar.gz

FROM luvx/base-0:${VERSION} AS vscode
COPY --from=vscode_downloader code /usr/bin
CMD ["sleep", "infinity"]

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM alpine:3.19 AS mysql_client

RUN echo "https://mirrors.aliyun.com/alpine/v3.19/main/" > /etc/apk/repositories \
    && echo "https://mirrors.aliyun.com/alpine/v3.19/community/" >> /etc/apk/repositories \
    && apk update && apk add --no-cache bash mysql-client

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
