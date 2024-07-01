# -------------资料-------------
# golang:1.22-alpine3.20: https://raw.githubusercontent.com/docker-library/golang/master/1.22/alpine3.20/Dockerfile
# python:3.12-alpine3.20: https://raw.githubusercontent.com/docker-library/python/master/3.12/alpine3.20/Dockerfile
ARG OS=bookworm
ARG GO_VERSION=1.22-${OS}
ARG PYTHON_VERSION=3.12-${OS}

FROM python:${PYTHON_VERSION}

WORKDIR /root

# -------------以下为安装Go-------------
ENV GOLANG_VERSION=1.22.4
ENV GOTOOLCHAIN=local
ENV GO111MODULE=on GOPROXY=https://goproxy.cn,direct
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

COPY --from=golang:1.22-bookworm --link /usr/local/go/ /usr/local/go/

# -------------以下为安装Java-------------
ENV JAVA_HOME=/opt/install/java
ENV PATH=$JAVA_HOME/bin:$PATH
# -------------以下为安装内核-------------

# RUN set -x \
#     && apk update \
#     && apk --no-cache --arch=x86_64 add \
#     ca-certificates g++ gcc git libffi-dev pkgconfig mercurial mesa-dev musl-dev su-exec zeromq-dev

# Kotlin 内核 来源: https://github.com/Kotlin/kotlin-jupyter
RUN pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple/ \
    && pip3 install --no-cache-dir jupyter kotlin-jupyter-kernel \
    # Java 内核
    && mkdir -p $JAVA_HOME && wget -q -O - "https://download.oracle.com/java/22/latest/jdk-22_linux-x64_bin.tar.gz" | tar -zxvf - -C $JAVA_HOME --strip-components 1 \
    && wget https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip \
    && unzip ijava-1.3.0.zip -d ijava && python3 ./ijava/install.py --sys-prefix && rm -fr ijava* \
    # Golang 内核: gophernotes(太旧,泛型都不支持)
    # && env GO111MODULE=on go install github.com/gopherdata/gophernotes@v0.7.5 \
    # && mkdir -p ~/.local/share/jupyter/kernels/gophernotes \
    # && cp /go/pkg/mod/github.com/gopherdata/gophernotes@v0.7.5/kernel/* ~/.local/share/jupyter/kernels/gophernotes \
    # && cd ~/.local/share/jupyter/kernels/gophernotes \
    # && chmod +w ./kernel.json \
    # && sed "s|gophernotes|$(go env GOPATH)/bin/gophernotes|" < kernel.json.in > kernel.json
    # Golang 内核: gonb
    && mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH" \
    && go install github.com/janpfeifer/gonb@latest \
    && go install golang.org/x/tools/cmd/goimports@latest \
    && go install golang.org/x/tools/gopls@latest \
    && gonb --install \
    # 清除
    && pip3 cache purge && go clean -cache && rm -fr ~/.cache \
    # 其他
    && mkdir -p $HOME/code

EXPOSE 8888
CMD [ "jupyter", "notebook", "--no-browser", "--allow-root", "--ip=0.0.0.0"]
