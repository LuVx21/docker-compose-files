#!/bin/bash

# mkdir -p $HOME/docker/redis_cluster/{cluster1,cluster2,cluster3,cluster4,cluster5,cluster6}/{conf,data,logs}
# chmod -R 777 $HOME/docker/redis_cluster/{cluster1,cluster2,cluster3,cluster4,cluster5,cluster6}/{conf,data,logs}
# echo $HOME/docker/redis_cluster/{cluster1,cluster2,cluster3,cluster4,cluster5,cluster6}/conf | xargs -n 1 cp -v ./cluster/redis.conf #修改端口号

for id in `seq 0 5`; do \
  DIR=$HOME/docker/redis_cluster/cluster_${id}
  mkdir -p $DIR/{conf,data,logs}
  chmod -R 777 $DIR/{conf,data,logs}

  let port=16379+$((id))
  let bus_port=10000+$((port))
  cat > $DIR/conf/redis.conf <<- EOF
port ${port}
#如果要设置密码需要增加如下配置：
requirepass 1121
#(设置集群节点间访问密码，跟上面一致)
masterauth 1121
protected-mode no
daemonize no
appendonly yes

# 数据根目录, 如rdb快照、aof文件、cluster-config-file指定的文件都在该目录下
dir /data
# 日志文件, 默认输出到控制台
logfile /logs/nodes.log

#启动集群模式
cluster-enabled yes
# 集群配置信息文件名, 记录了每个节点的地址、角色(master/slave)、slot等信息, 由redis自己生成, 位于数据目录下
cluster-config-file nodes.conf
cluster-node-timeout 15000
# 设置network_mode: "host"时使用
# cluster-announce-ip mini.rx
cluster-announce-port ${port}
# docker所在的宿主机总线映射端口
cluster-announce-bus-port ${bus_port}
bind 0.0.0.0

slave-read-only yes

EOF
done

docker compose -p redis-cluster -f ../docker-compose-cluster.yml up -d

# docker exec -it redis-cluster-0 redis-cli --cluster create redis-cluster-0:16379 redis-cluster-1:16380 redis-cluster-2:16381 redis-cluster-3:16382 redis-cluster-4:16383 redis-cluster-5:16384 --cluster-replicas 1 -a "1121" --cluster-yes

# docker exec -it redis-cluster-0 redis-cli -h redis-cluster-0 -p 16379 -a 1121 cluster info
# docker exec -it redis-cluster-0 redis-cli -h redis-cluster-0 -p 16379 -a 1121 cluster nodes
# docker exec -it redis-cluster-0 redis-cli -h redis-cluster-0 -p 16379 -a 1121 --cluster check redis-cluster-5:16384