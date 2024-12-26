#!/bin/bash

# 必需
module=$1
tag=$2
# 可选
buildArg=$3
platform=${4:-linux/amd64,linux/arm64}

minor=${tag%.*}
major=${tag%%.*}
if [[ -n $buildArg ]]; then
  for arg in $buildArg; do
    temp+="--build-arg $arg"
  done
  buildArg=$temp
fi

case "${module}" in
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
    cd sentinel-dashboard && sed -i "" "s/1.8.6/1.8.8/g" Dockerfile && sed -i "" "s/amd64\///g" Dockerfile
    ;;
  "base-0"|"base-1"|"base-2"|"ops"|"oracle_jdk"|"graalvm_jdk"|"mvnd"|"vscode"|"upx"|"duckdb"|"rocketmq-dashboard")
    url=https://github.com/LuVx21/docker-compose-files.git#master:luvx
    url="./luvx"
    target="--target $module"
    ;;
  *)
    echo "自定义构建镜像: ${module}"
    echo "执行命令: docker buildx build --push ${buildArg} --platform ${platform} ${module}"
    docker buildx build --push ${buildArg} --platform ${platform} ${module}
    exit 0
  ;;
esac;

image="luvx/$module"
echo "构建镜像: ${image} 版本: ${tag}, ${minor}, ${major} 架构: ${platform} 构建参数: ${buildArg} 上下文: ${url}"

echo "执行命令: docker buildx build --push ${buildArg} ${target} --platform ${platform} -t ${image}:latest -t ${image}:${tag} -t ${image}:${minor} -t ${image}:${major} ${url}"
docker buildx build --push ${buildArg} ${target} \
  --platform ${platform} \
  -t ${image}:latest \
  -t ${image}:${tag} \
  -t ${image}:${minor} \
  -t ${image}:${major} \
  ${url}