#!/bin/bash

# mkdir -p $HOME/docker/redis_sentinel/{master,sentinel,slave1,sentinel1,slave2,sentinel2}/{conf,data,logs}
# chmod -R 777 $HOME/docker/redis_sentinel/{master,sentinel,slave1,sentinel1,slave2,sentinel2}/{conf,data,logs}

for id in `seq 0 2`; do \
  REDIS=$HOME/docker/redis_sentinel/redis_${id}
  mkdir -p $REDIS/{conf,data,logs}
  chmod -R 777 $REDIS/{conf,data,logs}

  # 不使用默认接口时候放开
  let port=16379+$((id))

  if [ "$id" -gt "0" ]; then
    replicaof='replicaof redis-master 16379'
  fi

  cat > $REDIS/conf/redis.conf <<- EOF
port ${port}
appendonly yes
appendfilename appendonly.aof
appendfsync everysec
auto-aof-rewrite-min-size 10M
auto-aof-rewrite-percentage 100
requirepass "1121"

${replicaof}
masterauth "1121"
replica-read-only no

# 不在同一个网络使用
# 宿主机 ip,指定slave向master节点发送的ip信息
# replica-announce-ip mini.rx
# 映射到宿主机端口.指定slave向master节点发送的port信息
# replica-announce-port ${port}

EOF

done

# ==========================================

for id in `seq 0 2`; do \
  SENTINEL=$HOME/docker/redis_sentinel/sentinel_${id}
  mkdir -p $SENTINEL/{conf,data,logs}
  chmod -R 777 $SENTINEL/{conf,data,logs}

  # 不使用默认接口时候放开
  let port=16382+$((id))

  cat > $SENTINEL/conf/sentinel.conf <<- EOF
# 哨兵sentinel实例运行的端口
port ${port}
daemonize no
pidfile /var/run/redis-sentinel-${id}.pid
dir /tmp
sentinel resolve-hostnames yes
sentinel monitor mymaster redis-master 16379 2
sentinel auth-pass mymaster "1121"
# 指定多少毫秒之后 主节点没有应答哨兵sentinel 此时 哨兵主观上认为主节点下线 默认30秒
sentinel down-after-milliseconds mymaster 30000
# 指定了在发生failover主备切换时最多可以有多少个slave同时对新的master进行同步,这个数字越小，完成failover所需的时间就越长
sentinel parallel-syncs mymaster 1
# 故障转移的超时时间
sentinel failover-timeout mymaster 180000
sentinel deny-scripts-reconfig yes

# 不在同一个网络使用
# sentinel announce-ip mini.rx
# sentinel announce-port ${port}
# sentinel config-epoch mymaster 1
# sentinel leader-epoch mymaster 1

EOF

done

# ==========================================

docker compose -p redis-sentinel -f ../docker-compose-sentinel.yml up -d && \
docker exec -it redis-master redis-cli -p 16379 -a "1121" info Replication && \
docker exec -it redis-sentinel-0 redis-cli -p 16382 info Sentinel
