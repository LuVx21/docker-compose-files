# -------------资料-------------
# golang:1.23-alpine3.20: https://raw.githubusercontent.com/docker-library/golang/master/1.23/alpine3.20/Dockerfile
# python:3.12-alpine3.20: https://raw.githubusercontent.com/docker-library/python/master/3.12/alpine3.20/Dockerfile
ARG OS=bookworm
ARG GO_VERSION=1.23-${OS}
# ARG PYTHON_VERSION=3-slim-${OS}
ARG PYTHON_VERSION=3-${OS}

FROM python:${PYTHON_VERSION} AS base0

FROM base0 AS base-amd64
ARG ARCH=x64
FROM base0 AS base-arm64
ARG ARCH=aarch64

FROM base-$TARGETARCH AS base
WORKDIR /root

# -------------以下为安装Go-------------
# ENV GOLANG_VERSION=1.23.2
ENV GOTOOLCHAIN=local
ENV GO111MODULE=on GOPROXY=https://goproxy.cn,direct
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

COPY --from=golang:1.23-bookworm --link /usr/local/go/ /usr/local/go/

# -------------以下为安装Java-------------
ENV JAVA_HOME=/opt/install/java
ENV PATH=$JAVA_HOME/bin:$PATH
COPY --from=luvx/oracle_jdk:latest --link $JAVA_HOME $JAVA_HOME
# -------------以下为安装内核-------------

# Kotlin 内核 来源: https://github.com/Kotlin/kotlin-jupyter
RUN pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple/ \
    && pip3 install --no-cache-dir jupyterlab kotlin-jupyter-kernel && jupyter lab --generate-config \
    # Java 内核
    # && mkdir -p $JAVA_HOME && wget -q -O - "https://download.oracle.com/java/23/latest/jdk-23_linux-${ARCH}_bin.tar.gz" | tar -zxvf - -C $JAVA_HOME --strip-components 1 \
    && wget https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip \
    && unzip ijava-1.3.0.zip -d ijava && python3 ./ijava/install.py --sys-prefix && rm -fr ijava* \
    # Golang 内核: gophernotes(太旧,泛型都不支持)
    # && env GO111MODULE=on go install -ldflags="-w -s" github.com/gopherdata/gophernotes@v0.7.5 \
    # && mkdir -p ~/.local/share/jupyter/kernels/gophernotes \
    # && cp /go/pkg/mod/github.com/gopherdata/gophernotes@v0.7.5/kernel/* ~/.local/share/jupyter/kernels/gophernotes \
    # && cd ~/.local/share/jupyter/kernels/gophernotes \
    # && chmod +w ./kernel.json \
    # && sed "s|gophernotes|$(go env GOPATH)/bin/gophernotes|" < kernel.json.in > kernel.json
    # Golang 内核: gonb
    && mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH" \
    && go install -ldflags="-w -s" github.com/janpfeifer/gonb@latest \
    && go install -ldflags="-w -s" golang.org/x/tools/cmd/goimports@latest \
    && go install -ldflags="-w -s" golang.org/x/tools/gopls@latest \
    && gonb --install \
    # 清除
    && pip3 cache purge && go clean -cache && rm -fr ~/.cache \
    # 其他
    && mkdir -p $HOME/code

# Rust
ENV PATH=/root/.cargo/bin:$PATH
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && cargo install evcxr_jupyter && evcxr_jupyter --install

EXPOSE 8888
CMD [ "jupyter", "lab", "--no-browser", "--allow-root", "--ip=0.0.0.0", "--NotebookApp.allow_origin='*'"]