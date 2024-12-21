FROM python:3-bookworm AS jupyter
WORKDIR /root

# -------------以下为安装Go-------------
ENV GOTOOLCHAIN=local GO111MODULE=on GOPROXY=https://goproxy.cn,direct GOPATH=/go
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
    && wget https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip \
    && unzip ijava-1.3.0.zip -d ijava && python3 ./ijava/install.py --sys-prefix && rm -fr ijava* \
    # Golang 内核: gonb
    && mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH" \
    && go install -ldflags="-w -s" github.com/janpfeifer/gonb@latest \
    && go install -ldflags="-w -s" golang.org/x/tools/cmd/goimports@latest \
    && go install -ldflags="-w -s" golang.org/x/tools/gopls@latest \
    && gonb --install \
    # 清除
    && pip3 cache purge && go clean -cache && rm -fr /root/.cache /go/pkg \
    # 其他
    && mkdir -p $HOME/code

# -------------以下为安装Rust-------------
ENV PATH=/root/.cargo/bin:$PATH
COPY --from=rust:1-bookworm --link /usr/local/cargo/ /root/.cargo/
COPY --from=rust:1-bookworm --link /usr/local/rustup/ /root/.rustup/
# RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN cargo install evcxr_jupyter && evcxr_jupyter --install && cargo uninstall evcxr_jupyter; \
    # cargo install cargo-cache && cargo cache --remove-dir all; \
    rm -fr /root/.cargo/registry /root/.cargo/git

VOLUME ["/root/.m2", "/go/pkg"]
EXPOSE 8888
CMD [ "jupyter", "lab", "--no-browser", "--allow-root", "--ip=0.0.0.0", "--NotebookApp.allow_origin='*'"]