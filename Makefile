# SHELL := /bin/bash
CR_NS=

# -----------------------------------------------------------------------------------------------------------------------
test:
	docker build \
 	--target go-runner \
	--build-arg A=A \
 	--build-arg B=B \
	-t luvx/test:latest \
	.

	docker run --rm -it \
	--name test_$$(date +%s) \
	--network=net_common \
	--add-host="host.docker.internal:host-gateway" \
	-w /app \
	-v $$(pwd):/app \
# 	--entrypoint /bin/sh \ # 直接进入容器shell
	luvx/test:latest

# -----------------------------------------------------------------------------------------------------------------------
base-alpine:
	@for tag in 0 1 2 3; do \
		for os in 21 22; do \
			./build.sh base $$tag-alpine-$$os "VERSION=3.$$os,T=$$tag"; \
		done; \
	done
base:
	@for tag in 0 1 2 3; do \
		for os in bookworm trixie; do \
			tags="$$tag-$$os"; \
			if [ "$$os" = "trixie" ]; then \
				tags="$$tags,$$tag"; \
			fi; \
			if [ "$$tag" -eq 2 ]; then \
				tags="$$tags,latest"; \
			fi; \
			./build.sh base "$$tags" "VERSION=$$os,T=$$tag"; \
		done; \
	done
jdk:
	@for tag in 21 24 25; do \
		tags="$$tag"; \
		if [ "$$tag" = "25" ]; then \
			tags="$$tags,latest"; \
		fi; \
		./build.sh oracle_jdk  "$$tags" "JAVA_VERSION=$$tag"; \
		./build.sh graalvm_jdk "$$tags" "JAVA_VERSION=$$tag"; \
	done
mvnd:
	./build.sh mvnd latest,1 "MVND_VERSION=1.0.3"      linux/amd64
	./build.sh mvnd 2        "MVND_VERSION=2.0.0-rc-3" linux/amd64
iredis:
	./build.sh iredis latest,1      ""                linux/amd64 "--target=iredis ./luvx"
	./build.sh iredis latest-alpine "PACKAGES=iredis" ""          "--target=python-runner ./luvx/alpine"
	# ./build.sh iredis latest "PACKAGES=iredis" "" "--target=python-runner ./luvx"
vscode:
	./build.sh vscode latest-alpine "" "" ""
	./build.sh vscode latest
.PHONY: jupyter
jupyter:
	./build.sh jupyter latest "" "" "--target=jupyter"
	./build.sh jupyter vscode "" "" "--target=jupyter-vscode"
	./build.sh rust_base latest "" "" "--target=rust_base ./jupyter"
upx:
	./build.sh upx latest-alpine,5-alpine "UPX_VERSION=5.0.2"
	./build.sh upx latest,5               "UPX_VERSION=5.0.2"
duckdb:
	./build.sh duckdb latest
pichome:
	./build.sh pichome latest,2
mongosh:
	./build.sh mongosh latest "" "" "--target=mongosh ./luvx"
ldb:
	./build.sh ldb latest,10 "" "" "--target=ldb ./luvx"
rocketmq-dashboard:
	./build.sh rocketmq-dashboard latest,2 "RD_VERSION=2.1.0"
go-runner:
	./build.sh gore    latest-alpine "GO_INSTALL_URL=github.com/x-motemen/gore/cmd/gore@latest;golang.org/x/tools/gopls@latest" "" "--target=go-installer ./luvx/alpine"
	./build.sh hget    latest-alpine "GO_INSTALL_URL=github.com/huydx/hget@latest"                                              "" "--target=go-runner ./luvx/alpine"
	./build.sh glow    latest-alpine "GO_INSTALL_URL=github.com/charmbracelet/glow@latest"                                      "" "--target=go-runner ./luvx/alpine"
	./build.sh gum     latest-alpine "GO_INSTALL_URL=github.com/charmbracelet/gum@latest"                                       "" "--target=go-runner ./luvx/alpine"
	./build.sh pget    latest-alpine "GO_INSTALL_URL=github.com/Code-Hex/pget/cmd/pget@latest"                                  "" "--target=go-runner ./luvx/alpine"
	./build.sh crush   latest-alpine "GO_INSTALL_URL=github.com/charmbracelet/crush@latest"                                     "" "--target=go-runner ./luvx/alpine"
	./build.sh lazysql latest-alpine "GO_INSTALL_URL=github.com/jorgerojas26/lazysql@latest"                                    "" "--target=go-runner-scratch ./luvx/alpine"
# 	./build.sh lazygit latest-alpine "GO_INSTALL_URL=github.com/jesseduffield/lazygit@latest"                                   "" "--target=go-runner ./luvx/alpine"
	./build.sh lazydocker latest-alpine "GO_INSTALL_URL=github.com/jesseduffield/lazydocker@latest"                             "" "--target=go-runner-scratch ./luvx/alpine"
	./build.sh go-cyclic latest-alpine "GO_INSTALL_URL=github.com/elza2/go-cyclic@latest"                                       "" "--target=go-runner-scratch ./luvx/alpine"
# 	./build.sh octosql latest-alpine "GO_INSTALL_URL=github.com/cube2222/octosql@latest"                                        "" "--target=go-runner ./luvx/alpine"
# 	./build.sh usql    latest-alpine "GO_INSTALL_URL=github.com/xo/usql@latest"                                                 "" "--target=go-runner ./luvx/alpine"
	./build.sh gore latest "GO_INSTALL_URL=github.com/x-motemen/gore/cmd/gore@latest;golang.org/x/tools/gopls@latest" "" "--target=go-installer ./luvx"
python-runner:
	./build.sh litecli   latest-alpine "PACKAGES=litecli"   "" "--target=python-runner ./luvx/alpine"
	./build.sh mycli     latest-alpine "PACKAGES=mycli"     "" "--target=python-runner ./luvx/alpine"
	./build.sh pgcli     latest-alpine "PACKAGES=pgcli"     "" "--target=python-runner ./luvx/alpine"
	./build.sh toolong   latest-alpine "PACKAGES=toolong"   "" "--target=python-runner ./luvx/alpine"
	./build.sh frogmouth latest-alpine "PACKAGES=frogmouth" "" "--target=python-runner ./luvx/alpine"
	./build.sh dolphie   latest        "PACKAGES=dolphie"   "" "--target=python-runner ./luvx"

gemini:
	$(eval VERSION := 0.18.0)
	./build.sh gemini-cli   latest "CLI_VERSION_ARG=$(VERSION)"   "" "https://github.com/google-gemini/gemini-cli.git#v$(VERSION)"

# -----------------------------------------------------------------------------------------------------------------------

# -----------------------------------------------------------------------------------------------------------------------
dco-etcd:
	./dco.sh etcd

workflow-sync:
	gh workflow run sync.yml -f platform="linux/arm64,linux/amd64" -f dockerhub_images=debian:trixie,debian:trixie-slim,debian:latest

workflow-build:
	gh workflow run build.yml \
		-f image=alpine \
		-f tag=latest,3.22 \
		-f buildArg="VERSION=3.22" \
		# -f platform="linux/arm64,linux/amd64" \
		-f customArg="--target=alpine ./luvx/alpine"

workflow-custom:
	gh workflow run build.yml \
		-f image=custom \
		-f tag=xxx \
		-f customArg='make base base-alpine'