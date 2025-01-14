# SHELL := /bin/bash
CR_NS=

# -----------------------------------------------------------------------------------------------------------------------
base:
	./build.sh base-0 bookworm "VERSION=bookworm,CR=${CR_NS},T=0"
	./build.sh base-1 bookworm "VERSION=bookworm"
	./build.sh base-2 bookworm "VERSION=bookworm"
jdk:
	./build.sh oracle_jdk  23 "JAVA_VERSION=23"
	./build.sh graalvm_jdk 23 "JAVA_VERSION=23"
mvnd:
	./build.sh mvnd 1.0.2 "MVND_VERSION=1.0.2" linux/amd64
iredis:
	./build.sh iredis alpine-latest,alpine-1.15.0 "" "" "-f ./luvx/Dockerfile-alpine --target=iredis ./luvx"
	./build.sh iredis 1.15.0 "" linux/amd64 "--target=iredis ./luvx"
vscode:
	./build.sh vscode alpine-latest,alpine-1.96.2 "" "" "-f ./luvx/Dockerfile-alpine"
	./build.sh vscode 1.96.2
jupyter:
	./build.sh jupyter latest
upx:
	./build.sh upx alpine-latest,alpine-4.2.4 "UPX_VERSION=4.2.4" "" "-f ./luvx/Dockerfile-alpine"
	./build.sh upx 4.2.4 "UPX_VERSION=4.2.4"
duckdb:
	./build.sh duckdb latest
rocketmq-dashboard:
	./build.sh rocketmq-dashboard 2.0.0 "RD_VERSION=2.0.0"
go-runner:
	./build.sh xxx alpine-xxx "GO_INSTALL_URL=xxxx" "" "-f ./luvx/Dockerfile-alpine --target=go-runner ./luvx"
	./build.sh xxx xxx "GO_INSTALL_URL=xxxx" "" "--target=go-runner ."
python-runner:
	./build.sh toolong alpine-latest "PACKAGES=toolong" "" "-f ./luvx/Dockerfile-alpine --target=python-runner ./luvx"
	./build.sh dolphie alpine-latest "PACKAGES=dolphie" "" "-f ./luvx/Dockerfile-alpine --target=python-runner ./luvx"
	./build.sh frogmouth alpine-latest "PACKAGES=frogmouth" "" "-f ./luvx/Dockerfile-alpine --target=python-runner ./luvx"

# -----------------------------------------------------------------------------------------------------------------------
alpine:
	./build.sh alpine 3.20 "VERSION=3.20" "" "-f ./luvx/Dockerfile-alpine --target=alpine ./luvx"
	./build.sh alpine 3.21 "VERSION=3.21" "" "-f ./luvx/Dockerfile-alpine --target=alpine ./luvx"

dbcli:
	./build.sh litecli 1.13.2 "" "" "-f ./luvx/Dockerfile-alpine --target=litecli ./luvx"
	./build.sh mycli 1.29.2 "" "" "-f ./luvx/Dockerfile-alpine --target=mycli ./luvx"
	./build.sh pgcli 4.1.0 "" "" "-f ./luvx/Dockerfile-alpine --target=pgcli ./luvx"

# -----------------------------------------------------------------------------------------------------------------------
dco-etcd:
	./dco.sh etcd
