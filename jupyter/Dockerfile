ARG CR=${CR:-""}
ARG REGISTRY=${CR:+$CR/}
ARG VERSION=bookworm

# FROM ${REGISTRY}buildpack-deps:${VERSION} AS downloader

FROM ${REGISTRY}golang:1-${VERSION} AS go_base
COPY --from=luvx/upx:latest --link /usr/bin/upx /usr/bin/upx
RUN go install -ldflags="-w -s" github.com/janpfeifer/gonb@latest \
&& go install -ldflags="-w -s" golang.org/x/tools/cmd/goimports@latest \
&& go install -ldflags="-w -s" golang.org/x/tools/gopls@latest \
&& upx -9 /go/bin/*

FROM ${REGISTRY}rust:1-slim-${VERSION} AS rust_base
COPY --from=luvx/upx:latest --link /usr/bin/upx /usr/bin/upx
RUN cargo install evcxr_jupyter; \
    upx -9 $CARGO_HOME/bin/evcxr_jupyter; \
    rm -fr $CARGO_HOME/registry $CARGO_HOME/git

FROM ${REGISTRY}python:3-slim-${VERSION} AS jupyter
WORKDIR /root

# -------------以下为安装Go-------------
ENV GOTOOLCHAIN=local GO111MODULE=on GOPROXY=https://goproxy.cn,direct GOPATH=/go GOROOT=/usr/local/go
ENV PATH=$GOPATH/bin:$GOROOT/bin:$PATH
COPY --from=go_base --link $GOROOT $GOROOT
COPY --from=go_base --link $GOPATH/bin/ $GOPATH/bin/

# -------------以下为安装Java-------------
ENV JAVA_HOME=/opt/install/java
ENV PATH=$JAVA_HOME/bin:$PATH
COPY --from=luvx/oracle_jdk:latest --link $JAVA_HOME $JAVA_HOME

# -------------以下为安装内核-------------

# Kotlin 内核 来源: https://github.com/Kotlin/kotlin-jupyter
RUN apt-get update && apt-get install -y --no-install-recommends wget unzip && rm -rf /var/lib/apt/lists/*; \
    pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple/ \
    && sed -i 's|deb.debian.org|mirrors.aliyun.com|g' /etc/apt/sources.list.d/debian.sources \
    && pip3 install --no-cache-dir jupyterlab kotlin-jupyter-kernel && jupyter lab --generate-config \
    && wget https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip \
    && unzip ijava-1.3.0.zip -d ijava && python3 ./ijava/install.py --sys-prefix && rm -fr ijava* \
    # Golang 内核: gonb
    # && mkdir -p "$GOPATH/src" "$GOPATH/bin" \
    # && chmod -R 1777 "$GOPATH" \
    && gonb --install \
    # 清除
    && pip3 cache purge && go clean -cache && rm -fr /root/.cache /go/pkg \
    # 其他
    && mkdir -p $HOME/code

# -------------以下为安装Rust-------------
ENV CARGO_HOME=/usr/local/cargo RUSTUP_HOME=/usr/local/rustup
ENV PATH=$CARGO_HOME/bin:$PATH
COPY --from=rust_base --link $CARGO_HOME $CARGO_HOME
COPY --from=rust_base --link $RUSTUP_HOME $RUSTUP_HOME
# RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN evcxr_jupyter --install; \
    # cargo install cargo-cache && cargo cache --remove-dir all; \
    rm -fr $CARGO_HOME/registry $CARGO_HOME/git

VOLUME ["/root/.m2", "/go/pkg"]
EXPOSE 8888
CMD [ "jupyter", "lab", "--no-browser", "--allow-root", "--ip=0.0.0.0", "--NotebookApp.allow_origin='*'", "--NotebookApp.token=''", "--NotebookApp.password=''", "NotebookApp.disable_check_xsrf=True" ]

# 也可以这样, 在启动容器时再指定具体参数
# ENTRYPOINT [ "jupyter", "lab" ]
