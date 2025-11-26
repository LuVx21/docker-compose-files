#!/bin/bash

# 必需
repository=$1
tag=$2 # 支持多个,逗号分割
# 可选
buildArg=$3 # 支持多个,逗号分割
platform=${4:-linux/arm64,linux/amd64}
CUSTOM_ARG=$5

os=$(uname -s)


# if [[ ! $tag =~ 'alpine' ]]; then
#   tags+=("latest")
# fi
for _tag in ${tag//,/ }; do
  if [[ $_tag == *-* ]]; then
    # 提取出第一个-前和后的内容
    prefix="${_tag%%-*}" suffix="${_tag#*-}"
    # -前内容处理版本号
    major="${prefix%%.*}-${suffix}" minor="${prefix%.*}-${suffix}"
  else
    major="${_tag%%.*}" minor="${_tag%.*}"
  fi
  tags+=($_tag ${major} ${minor})
done
tags=($(echo "${tags[@]}" | tr ' ' '\n' | sort | uniq | tr '\n' ' '))
if [[ -n $buildArg ]]; then
  for arg in ${buildArg//,/ }; do
    temp+="--build-arg $arg "
  done
  buildArg=$temp
fi

case "${repository}" in
  "chartdb")
    url=https://github.com/chartdb/chartdb.git#v$tag
    ;;
  "dicedb")
    url=https://github.com/DiceDB/dice.git#v$tag
    ;;
  "json4u")
    url=https://github.com/loggerhead/json4u.git#v$tag
    ;;
  "jupyter")
    url=https://github.com/LuVx21/docker-compose-files.git#master:jupyter
    url="./jupyter"
    ;;
  "pichome")
    url=https://github.com/zyx0814/Pichome-docker.git
    ;;
  "sentinel-dashboard")
    curl https://raw.githubusercontent.com/alibaba/Sentinel/master/sentinel-dashboard/Dockerfile > ./sentinel-dashboard/Dockerfile
    cd sentinel-dashboard && sed -i "" "s/1.8.6/1.8.9/g" Dockerfile && sed -i "" "s/amd64\///g" Dockerfile
    url="."
    ;;
  "base"|"oracle_jdk"|"graalvm_jdk"|"mvnd"|"vscode"|"upx"|"duckdb"|"rocketmq-dashboard")
    url=https://github.com/LuVx21/docker-compose-files.git#master:luvx
    [[ $tag =~ 'alpine' ]] && url="./luvx/alpine" || url="./luvx"
    target="--target ${repository}"
    ;;
  *)
    # exit 0
  ;;
esac;

image="luvx/${repository}"
echo "构建镜像: ${image} 版本: ${tags[@]} 架构: ${platform} 构建参数: ${buildArg} 上下文: ${url} 自定义参数: ${CUSTOM_ARG}"

for _tag in ${tags[@]}; do
  if [[ ! $os == 'Darwin' ]]; then
    image_info+="-t ${image}:${_tag} -t ghcr.io/luvx21/${repository}:${_tag} "
  else
    image_info+="-t ${TX_CR}/${image}:${_tag} "
  fi
  image_info+="-t ${ALI_CR}/${image}:${_tag} "
done

echo "执行命令: docker buildx build --push --build-arg CR=${ALI_CR_NS} ${buildArg} ${target} --platform ${platform} ${image_info} ${url} ${CUSTOM_ARG}" | sed -E 's/ (--|-t)/\n\1/g'
docker buildx build --push --build-arg CR=${ALI_CR_NS} ${buildArg} ${target} \
  --platform ${platform} \
  ${image_info} \
  ${url} ${CUSTOM_ARG} # --output type=docker,dest=- | docker load # 推送的同时本地也有一份
