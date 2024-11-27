ARG IMAGE=buildpack-deps
ARG VERSION=curl

FROM ${IMAGE}:${VERSION} AS base0
FROM base0 AS base-amd64
ARG ARCH=x64
FROM base0 AS base-arm64
ARG ARCH=aarch64

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
