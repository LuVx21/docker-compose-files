#!/bin/bash

url=''
file=''

if [ "$1" = "" ];
then
    echo -e "需指定模块名"
    exit 1
elif [ "$1" = "update" ];then
    # docker images | tail +2 | grep -v luvx | awk '{print $1,$2}' | sed 's/ /:/g' | xargs -I F docker pull F
    images=`docker container ls -a | tail +2 | grep -v luvx | awk '{print $2}' | sort | uniq`
    for image in $images; do
        echo '更新...'$image
        docker pull $image
    done
    exit 0
elif [ "$1" = "backup" ];then
    if [ "$2" = "" ];then
        echo -e "需指定镜像Id"
        exit 1
    fi
    image=`docker images | grep $2 | awk '{print $1}' | sed 's/\//_/g'`
    version=`docker images | grep $2 | awk '{print $2}'`

    for registry in 'registry.cn-shanghai.aliyuncs.com' 'ccr.ccs.tencentyun.com'; do
        nimage=$registry/luvx21/$image
        echo '备份为->'$nimage:$version
        docker tag $2 $nimage:$version
        docker push $nimage:$version && docker image rm $nimage:$version
    done
    exit 0
elif [ "$1" = "etcd" ];then
    url='https://raw.githubusercontent.com/bitnami/containers/main/bitnami/etcd/docker-compose-cluster.yml'
    file='etcd-docker-compose-cluster.yml'
else
    echo -e "无指定模块名"
    exit 1
fi

if [ -f $file ];then
  echo "使用现有文件:" $file
else
  echo $file "文件不存在"
  curl -L $url -o $file
fi


if [ "$2" = "down" ];
then
    docker-compose -p $1 -f $file down
else
    list=`docker-compose -p $1 -f $file ps | tail -n +2 | awk '{print $1}'`
    if [ -z "$list" ]; then
        echo "开始运行..."
        docker-compose -p $1 -f $file up -d
        # 加入网络
        list=`docker-compose -p $1 -f $file ps | tail -n +2 | awk '{print $1}'`
        for i in $list; do
            echo $i '加入网络:net_common'
            docker network connect net_common $i
        done
    else
        echo "已经运行"
        exit 1
    fi
fi
