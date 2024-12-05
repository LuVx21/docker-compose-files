ARG IMAGE=buildpack-deps
ARG VERSION=curl

FROM ${IMAGE}:${VERSION} AS base0
FROM base0 AS base-amd64
ARG ARCH=x64
ARG ARCH_SHORT=x64
FROM base0 AS base-arm64
ARG ARCH=aarch64
ARG ARCH_SHORT=arm64

FROM base-$TARGETARCH AS base
WORKDIR /workspace

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM base AS ops

RUN apt update && apt install -y zsh curl wget tree vim git
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM base AS oracle_jdk

ENV JAVA_HOME=/opt/install/java
ENV PATH=$JAVA_HOME/bin:$PATH

RUN mkdir -p $JAVA_HOME && wget -q -O - "https://download.oracle.com/java/23/latest/jdk-23_linux-${ARCH}_bin.tar.gz" | tar -zxvf - -C $JAVA_HOME --strip-components 1

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM base AS graalvm_jdk

ENV JAVA_HOME=/opt/install/java
ENV PATH=$JAVA_HOME/bin:$PATH

RUN mkdir -p $JAVA_HOME && wget -q -O - "https://download.oracle.com/graalvm/23/latest/graalvm-jdk-23_linux-${ARCH}_bin.tar.gz" | tar -zxvf - -C $JAVA_HOME --strip-components 1

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# docker build --target mvnd -t luvx/mvnd:1.0.2-23 --platform linux/amd64 --build-arg MVND_VERSION=1.0.2 .
FROM base0 AS downloader

ARG MVND_VERSION='1.0.2' PLATFORM=linux ARCH=amd64
RUN curl -fSL -o maven-mvnd.tar.gz https://github.com/apache/maven-mvnd/releases/download/${MVND_VERSION}/maven-mvnd-${MVND_VERSION}-${PLATFORM}-${ARCH}.tar.gz

FROM eclipse-temurin:23 AS mvnd

ENV MVND_HOME=/opt/install/mvnd
ENV PATH=$MVND_HOME/bin:$MVND_HOME/mvn/bin:$PATH

COPY --from=downloader maven-mvnd.tar.gz .
RUN mkdir -p $MVND_HOME && tar --strip-components=1 -xzf maven-mvnd.tar.gz -C $MVND_HOME \
    && rm -rf maven-mvnd.tar.gz

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FROM base AS vscode

RUN wget -q -O vscode_cli_alpine_${ARCH_SHORT}_cli.tar.gz "https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-${ARCH_SHORT}" \
    && tar -zxvf vscode_cli_alpine_${ARCH_SHORT}_cli.tar.gz -C /usr/bin
CMD ["sleep" "infinity"]

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
