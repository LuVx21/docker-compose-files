ARG IMAGE=ubuntu
ARG VERSION=latest

FROM ${IMAGE}:${VERSION}

WORKDIR /workspace

# ENV

RUN apt update && apt install -y curl wget tree vim git
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
