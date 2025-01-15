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
	./build.sh iredis 1.15.0 "" linux/amd64 "--target=iredis ./luvx"
	./build.sh iredis latest-alpine "PACKAGES=iredis" "" "--target=python-runner ./luvx/alpine"
	# ./build.sh iredis latest "PACKAGES=iredis" "" "--target=python-runner ./luvx"
vscode:
	./build.sh vscode latest-alpine "" "" ""
	./build.sh vscode latest
jupyter:
	./build.sh jupyter latest
upx:
	./build.sh upx latest-alpine,4.2.4-alpine "UPX_VERSION=4.2.4" "" ""
	./build.sh upx 4.2.4 "UPX_VERSION=4.2.4"
.PHONY: duckdb
duckdb:
	./build.sh duckdb latest
rocketmq-dashboard:
	./build.sh rocketmq-dashboard 2.0.0 "RD_VERSION=2.0.0"
go-runner:
	./build.sh xxx latest-alpine "GO_INSTALL_URL=xxxx" "" "--target=go-runner ./luvx/alpine"
	./build.sh xxx latest "GO_INSTALL_URL=xxxx" "" "--target=go-runner ."
python-runner:
	./build.sh litecli   latest-alpine "PACKAGES=litecli"   "" "--target=python-runner ./luvx/alpine"
	./build.sh mycli     latest-alpine "PACKAGES=mycli"     "" "--target=python-runner ./luvx/alpine"
	./build.sh pgcli     latest-alpine "PACKAGES=pgcli"     "" "--target=python-runner ./luvx/alpine"
	./build.sh toolong   latest-alpine "PACKAGES=toolong"   "" "--target=python-runner ./luvx/alpine"
	./build.sh frogmouth latest-alpine "PACKAGES=frogmouth" "" "--target=python-runner ./luvx/alpine"
	./build.sh dolphie   latest "PACKAGES=dolphie"          "" "--target=python-runner ./luvx"

# -----------------------------------------------------------------------------------------------------------------------
alpine:
	./build.sh alpine 3.20 "VERSION=3.20" "" "--target=alpine ./luvx/alpine"
	./build.sh alpine 3.21 "VERSION=3.21" "" "--target=alpine ./luvx/alpine"

# -----------------------------------------------------------------------------------------------------------------------
dco-etcd:
	./dco.sh etcd
