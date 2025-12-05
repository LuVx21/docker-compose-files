ARG CR=${CR:-""}
ARG REGISTRY=${CR:+$CR/}
ARG VERSION=trixie

# FROM ${REGISTRY}buildpack-deps:${VERSION} AS downloader

FROM ${REGISTRY}golang:1-${VERSION} AS go_base
COPY --from=luvx/upx:latest --link /usr/bin/upx /usr/bin/upx
RUN go install -ldflags="-w -s" github.com/janpfeifer/gonb@latest \
&& go install -ldflags="-w -s" golang.org/x/tools/cmd/goimports@latest \
&& go install -ldflags="-w -s" golang.org/x/tools/gopls@latest \
&& go install -ldflags="-w -s" github.com/go-delve/delve/cmd/dlv@latest \
&& go install -ldflags="-w -s" honnef.co/go/tools/cmd/staticcheck@latest \
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
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH=$JAVA_HOME/bin:$PATH
COPY --from=eclipse-temurin:25-jdk --link $JAVA_HOME $JAVA_HOME

# -------------以下为安装内核-------------

RUN pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple/; \
    sed -i 's|deb.debian.org|mirrors.aliyun.com|g' /etc/apt/sources.list.d/debian.sources; \
    # slim镜像时使用
    apt-get update -q && \
    apt-get install -q -y --no-install-recommends curl && \
    apt-get install -q -y --no-install-recommends wget unzip openssl ca-certificates build-essential libssl-dev pkg-config && rm -rf /var/lib/apt/lists/*; \
    curl https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/refs/heads/master/templates/minimal.zshrc > /root/.zshrc; \
    sed -i "s|git|git history-substring-search z zsh-autosuggestions zsh-completions zsh-syntax-highlighting|g" /root/.zshrc;

# Kotlin 内核 来源: https://github.com/Kotlin/kotlin-jupyter
RUN pip3 install --no-cache-dir jupyterlab kotlin-jupyter-kernel catppuccin-jupyterlab && jupyter lab --generate-config \
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
RUN curl https://raw.githubusercontent.com/LuVx21/coding-config/refs/heads/main/rust/config.toml > $CARGO_HOME/config.toml; \
    evcxr_jupyter --install; \
    # cargo install cargo-cache && cargo cache --remove-dir all; \
    rm -fr $CARGO_HOME/registry $CARGO_HOME/git

VOLUME ["/root/.m2", "/go/pkg", "$CARGO_HOME/registry"]
EXPOSE 8888
RUN <<EOT bash
    echo "#!/bin/sh" >> /entrypoint.sh
    echo 'rustup --version;cargo --version;rustc --version;go version;java -version;python --version;' >> /entrypoint.sh
    echo '/usr/bin/code update;' >> /entrypoint.sh
    echo 'pip install --upgrade pip;' >> /entrypoint.sh
    echo 'if [ -z \$(which curl) ]; then pkg=\$pkg" curl ca-certificates"; fi;' >> /entrypoint.sh
    echo 'if [ -z \$(which jq) ]; then pkg=\$pkg" jq"; fi;' >> /entrypoint.sh
    echo 'if [ -z \$(which git) ]; then pkg=\$pkg" git"; fi;' >> /entrypoint.sh
    echo 'if [ -z \$(which zsh) ]; then pkg=\$pkg" zsh"; fi;' >> /entrypoint.sh
    echo 'if [ -z \$(which sudo) ]; then pkg=\$pkg" sudo"; fi;' >> /entrypoint.sh
    echo 'apt-get update -q && apt-get install -q -y --no-install-recommends \$pkg;' >> /entrypoint.sh
    echo 'chsh -s \$(which zsh);' >> /entrypoint.sh
    echo -n "jupyter lab --no-browser --allow-root --ip=0.0.0.0 --ServerApp.allow_origin='*' --IdentityProvider.token='' --ServerApp.password='' --ServerApp.disable_check_xsrf=True" >> /entrypoint.sh
    chmod +x /entrypoint.sh
EOT
CMD ["/entrypoint.sh"]

# 也可以这样, 在启动容器时再指定具体参数
# ENTRYPOINT [ "jupyter", "lab" ]

FROM luvx/jupyter:latest AS jupyter-vscode
# RUN groupadd -r luvx && useradd -r -m -g luvx -s /bin/bash luvx
# USER luvx
COPY --from=luvx/vscode:latest-alpine --link /usr/bin/code /usr/bin/code
VOLUME ["/root/.vscode", "/root/.vscode-server"]
EXPOSE 8000
RUN <<EOT bash
    echo " &" >> /entrypoint.sh
    echo -n "code serve-web --host=0.0.0.0 --port=8000 --without-connection-token" >> /entrypoint.sh
EOT
HEALTHCHECK --interval=30s --timeout=3s CMD curl -f http://localhost:8000 || exit 1
