#!/bin/zsh

MAIN_HOME=$HOME/docker/mysql
# rm -fr $MAIN_HOME
mkdir -p $MAIN_HOME/{mysql_0,mysql_1,mysql_2}/{conf,data,init,logs}

cat ./my.cnf > $MAIN_HOME/mysql_0/my.cnf
for id in `seq 1 2`; do \
  let server_id=20001+$((id))
  SERVER_ID=${server_id} envsubst < my-slave.cnf > $MAIN_HOME/mysql_${id}/my.cnf
done

(( ${+commands[docker-compose]} )) && dco='docker-compose' || dco='docker compose'
$dco -f ../docker-compose.yml up --build -d
echo `date`: "启动完成!"

sleep 20
echo `date`: "主从创建!"

function test_func()
{
    docker exec -it $1 mysql -u root -p1121 -e "grant select,replication slave,replication client on *.* to 'slave'@'%' identified by \"1121\";flush privileges;"

    # 最新位置开始
    # RESULT=`docker exec -it $2 mysql -h $1 -u slave  -p1121 -e "show master status;" | tail -2 | head -1 | awk '{print $2,$4}'`
    LOG_FILE_NAME="mysql-bin.000001" # `echo $RESULT | awk '{print $1}'`
    LOG_FILE_POS=0 # `echo $RESULT | awk '{print $2}'`

    docker exec -it $2 mysql -u root -p1121 -e "change master to master_host='$1',master_port=3306,master_user='slave',master_password='1121',master_log_file='$LOG_FILE_NAME', master_log_pos=$LOG_FILE_POS,master_connect_retry=30;start slave;"
}

test_func mysql-master mysql-slave-1
test_func mysql-slave-1 mysql-slave-2

sleep 10
echo `date`: "设置从库只读!"
# 从库配置只读
for id in `seq 1 2`; do \

  sed -i "" 's/# super_read_only=1/super_read_only=1/g' $MAIN_HOME/mysql_${id}/my.cnf
  sed -i "" 's/# read_only=1/read_only=1/g' $MAIN_HOME/mysql_${id}/my.cnf

#   cat >> $MAIN_HOME/mysql_${id}/my.cnf <<- EOF

# super_read_only=1
# read_only=1

# EOF
  docker container restart mysql-slave-${id}
done

echo `date`: "完成!"
