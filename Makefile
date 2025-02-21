# SHELL := /bin/bash
CR_NS=

# -----------------------------------------------------------------------------------------------------------------------
base-alpine:
	./build.sh base 0-alpine "VERSION=3.21,T=0"
	./build.sh base 1-alpine "VERSION=3.21,T=1"
	./build.sh base 2-alpine "VERSION=3.21,T=2"
	./build.sh base 3-alpine "VERSION=3.21,T=3"
base:
	./build.sh base 0,0-bookworm "VERSION=bookworm,T=0"
	./build.sh base 1,1-bookworm "VERSION=bookworm,T=1"
	./build.sh base latest,2,2-bookworm "VERSION=bookworm,T=2"
	./build.sh base 3,3-bookworm "VERSION=bookworm,T=3"
jdk:
	./build.sh oracle_jdk  latest,23 "JAVA_VERSION=23"
	./build.sh graalvm_jdk latest,23 "JAVA_VERSION=23"
mvnd:
	./build.sh mvnd latest,1.0.2 "MVND_VERSION=1.0.2" linux/amd64
iredis:
	./build.sh iredis latest,1.15.0 "" linux/amd64 "--target=iredis ./luvx"
	./build.sh iredis latest-alpine "PACKAGES=iredis" "" "--target=python-runner ./luvx/alpine"
	# ./build.sh iredis latest "PACKAGES=iredis" "" "--target=python-runner ./luvx"
vscode:
	./build.sh vscode latest-alpine "" "" ""
	./build.sh vscode latest
.PHONY: jupyter
jupyter:
	./build.sh jupyter latest "" "" "--target=jupyter"
	./build.sh jupyter vscode "" "" "--target=jupyter-vscode"
upx:
	./build.sh upx latest-alpine,5.0.0-alpine "UPX_VERSION=5.0.0" "" ""
	./build.sh upx latest,5.0.0 "UPX_VERSION=5.0.0"
.PHONY: duckdb
duckdb:
	./build.sh duckdb latest,latest-alpine "" "" "--target=duckdb ./luvx/alpine"
rocketmq-dashboard:
	./build.sh rocketmq-dashboard latest,2.0.0 "RD_VERSION=2.0.0"
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

# -----------------------------------------------------------------------------------------------------------------------
dco-etcd:
	./dco.sh etcd

workflow-sync:
	gh workflow run sync.yml -f platform="linux/arm64,linux/amd64" -f dockerhub_images=debian:bookworm,debian:bookworm-slim,debian:latest

workflow-build:
	gh workflow run build.yml \
		-f image=alpine \
		-f tag=latest,3.21 \
		-f buildArg="VERSION=3.21" \
		# -f platform="linux/arm64,linux/amd64" \
		-f customArg="--target=alpine ./luvx/alpine"

workflow-custom:
	gh workflow run build.yml \
		-f image=custom \
		-f tag=xxx \
		-f customArg="make base alpine"