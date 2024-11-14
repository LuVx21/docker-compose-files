#!/bin/bash

image='' version='' url='.'

if [ "$1" = "" ];then
    exit 1
elif [ "$1" = "chartdb" ];then
    image='luvx/chartdb' version='v1.2.0' url=https://github.com/chartdb/chartdb.git#"$version"
elif [ "$1" = "dicedb" ];then
    image='luvx/dicedb' version='0.0.5' url=https://github.com/DiceDB/dice.git#"$version"
elif [ "$1" = "duckdb" ];then
    image='luvx/duckdb' version='v1.1.3' url=https://github.com/LuVx21/docker-compose-files.git#master:duckdb
    # url='../duckdb'
elif [ "$1" = "json4u" ];then
    image='luvx/json4u' version='v3.0.0' url=https://github.com/loggerhead/json4u.git#"$version"
elif [ "$1" = "jupyter" ];then
    image='luvx/jupyter' version='0' url=https://github.com/LuVx21/docker-compose-files.git#master:jupyter
    # url='../jupyter'
elif [ "$1" = "pichome" ];then
    image='luvx/pichome' version='2.0' url=https://github.com/zyx0814/Pichome-docker.git
elif [ "$1" = "sentinel" ];then
    image='luvx/sentinel-dashboard' version='1.8.8'
    curl https://raw.githubusercontent.com/alibaba/Sentinel/master/sentinel-dashboard/Dockerfile > ./sentinel-dashboard/Dockerfile
    cd sentinel-dashboard && sed -i "" 's/1.8.6/1.8.8/g' Dockerfile && sed -i "" 's/amd64\///g' Dockerfile
else
    echo -e "无指定模块名"
    exit 1
fi


echo "构建镜像: ${image}:${version} 上下文: ${url}"
docker buildx build \
    -t "$image":latest -t "$image":"$version" \
    --platform linux/amd64,linux/arm64 --push "$url"

echo "完成......"