#!/bin/bash

project=$1
subcmd=$2
url=''
file=''

if [ "$project" = "" ]; then
    echo -e "需指定模块名"
    exit 1
elif [ "$project" = "bitnami-etcd" ]; then
    url='https://raw.githubusercontent.com/bitnami/containers/main/bitnami/etcd/docker-compose-cluster.yml'
    file='etcd-docker-compose-cluster.yml'
elif [ "$project" = "bitnami-kafka" ]; then
    url='https://raw.githubusercontent.com/bitnami/containers/refs/heads/main/bitnami/kafka/docker-compose-cluster.yml'
    file='kafka-docker-compose-cluster.yml'
elif [ "$project" = "file-transfer-go" ]; then
    url='https://raw.githubusercontent.com/MatrixSeven/file-transfer-go/refs/heads/main/docker-compose.yml'
    file='file-transfer-go-docker-compose.yml'
else
    echo -e "无指定模块名"
    exit 1
fi

if [ -f $file ]; then
  echo "使用现有文件:" $file
else
  echo $file "文件不存在"
  curl -L $url -o $file
fi


if [ "$subcmd" = "down" ]; then
    docker-compose -p $project -f $file down
else
    list=`docker-compose -p $project -f $file ps | tail -n +2 | awk '{print $1}'`
    if [ -z "$list" ]; then
        echo "开始运行..."
        docker-compose -p $project -f $file up -d
        # 加入网络
        list=`docker-compose -p $project -f $file ps | tail -n +2 | awk '{print $1}'`
        for i in $list; do
            echo $i '加入网络:net_common'
            docker network connect net_common $i
        done
    else
        echo "已经运行"
        exit 1
    fi
fi
