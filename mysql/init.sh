#!/bin/bash


mkdir -p $HOME/docker/mysql/{mysql_0,mysql_1,mysql_2}/{conf,data,init,logs}

cat ./my.cnf > $HOME/docker/mysql/mysql_0/my.cnf

for id in `seq 1 2`; do \
  let server_id=20001+$((id))
  SERVER_ID=${server_id} envsubst < my-slave.cnf > $HOME/docker/mysql/mysql_${id}/my.cnf
done

docker compose -f docker-compose.yml up -d

# master
# grant replication slave,replication client on *.* to 'slave'@'%' identified by "1121";
# flush privileges;

# slave
# change master to master_host='mysql-master',master_port=3306,master_user='slave',master_password='1121',master_log_file='mysql-bin.000001', master_log_pos=0,master_connect_retry=30;
# change master to master_host='mysql-slave-1',master_port=3306,master_user='slave',master_password='1121',master_log_file='mysql-bin.000001', master_log_pos=0,master_connect_retry=30;
# start slave;
