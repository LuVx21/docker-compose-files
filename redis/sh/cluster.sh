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

#启动集群模式
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 15000
cluster-announce-ip mini.rx
cluster-announce-port ${port}
cluster-announce-bus-port ${bus_port}
bind 0.0.0.0

EOF
done

docker compose -p redis-cluster -f ../docker-compose-cluster.yml up -d && \
docker exec -it redis-cluster-0 redis-cli --cluster create mini.rx:16379 mini.rx:16380 mini.rx:16381 mini.rx:16382 mini.rx:16383 mini.rx:16384 --cluster-replicas 1 -a "1121"

# docker exec -it redis-cluster-0 redis-cli -h mini.rx -p 16379 -a 1121 cluster info
# docker exec -it redis-cluster-0 redis-cli -h mini.rx -p 16379 -a 1121 cluster nodes
# docker exec -it redis-cluster-0 redis-cli -h mini.rx -p 16379 -a 1121 --cluster check mini.rx:16384