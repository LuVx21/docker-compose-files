# SHELL := /bin/bash
CR_NS=

# -----------------------------------------------------------------------------------------------------------------------
base:
	./build.sh base-0 latest,bookworm "VERSION=bookworm,CR=${CR_NS},T=0"
	./build.sh base-1 latest,bookworm "VERSION=bookworm"
	./build.sh base-2 latest,bookworm "VERSION=bookworm"
jdk:
	./build.sh oracle_jdk  23 "JAVA_VERSION=23"
	./build.sh graalvm_jdk 23 "JAVA_VERSION=23"
mvnd:
	./build.sh mvnd 1.0.2 "MVND_VERSION=1.0.2" linux/amd64
vscode:
	./build.sh vscode 1.96.2
	./build.sh vscode alpine-1.96.2 "" "" "-f ./luvx/Dockerfile-alpine"
jupyter:
	./build.sh jupyter latest
upx:
	./build.sh upx 4.2.4 "UPX_VERSION=4.2.4"
duckdb:
	./build.sh duckdb latest
rocketmq-dashboard:
	./build.sh rocketmq-dashboard 2.0.0 "RD_VERSION=2.0.0"
go-runner:
	./build.sh xxx xxx "GO_INSTALL_URL=xxxx" "linux/amd64,linux/arm64" "--target=go-runner ."

# -----------------------------------------------------------------------------------------------------------------------
alpine:
	./build.sh alpine 3.20 "VERSION=3.20" "" "-f ./luvx/Dockerfile-alpine --target=alpine ./luvx"
	./build.sh alpine 3.21 "VERSION=3.21" "" "-f ./luvx/Dockerfile-alpine --target=alpine ./luvx"

cli:
	./build.sh litecli 1.13.2 "" "" "-f ./luvx/Dockerfile-alpine --target=litecli ./luvx"
	./build.sh mycli 1.29.2 "" "" "-f ./luvx/Dockerfile-alpine --target=mycli ./luvx"
	./build.sh pgcli 4.1.0 "" "" "-f ./luvx/Dockerfile-alpine --target=pgcli ./luvx"

# -----------------------------------------------------------------------------------------------------------------------
dco-etcd:
	./dco.sh etcd
