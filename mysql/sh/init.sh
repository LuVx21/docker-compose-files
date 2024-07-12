#!/bin/zsh

export VERSION=8
export name=mysql$VERSION
MAIN_HOME=$HOME/docker/$name
# rm -fr $MAIN_HOME
mkdir -p $MAIN_HOME/{mysql_0,mysql_1,mysql_2}/{conf,data,init,logs}

cat ./my.cnf > $MAIN_HOME/mysql_0/my.cnf
for id in `seq 1 2`; do \
    let server_id=20001+$((id))
    SERVER_ID=${server_id} envsubst < my-slave.cnf > $MAIN_HOME/mysql_${id}/my.cnf
done

(( ${+commands[docker-compose]} )) && dco='docker-compose' || dco='docker compose'
$dco -p mysql${VERSION: -1} -f ../docker-compose.yml up --build -d
echo `date`: "启动完成!"

sleep 20
echo `date`: "主从创建!"

function link()
{
    # docker exec $2 sh -c 'export MYSQL_PWD=1121; mysql -h $1 -u slave -e "show master status;"'
    # 最新位置开始
    # RESULT=`docker exec -it $2 mysql -h $1 -u slave -p1121 -e "show master status;" | tail -2 | head -1 | awk '{print $2,$4}'`
    LOG_FILE_NAME="mysql-bin.000001" # `echo $RESULT | awk '{print $1}'`
    LOG_FILE_POS=0 # `echo $RESULT | awk '{print $2}'`
    if [ "$VERSION" = "8" ];then
        docker exec -it $1 mysql -u root -p1121 -e "create user 'slave'@'%' identified by \"1121\";grant select,replication slave,replication client on *.* to 'slave'@'%';flush privileges;"

        docker exec -it $2 mysql -u root -p1121 -e "change replication source to source_host='$1',source_port=3306,source_user='slave',source_password='1121',source_log_file='$LOG_FILE_NAME', source_log_pos=$LOG_FILE_POS,source_connect_retry=30,get_source_public_key=1;start replica;"
    else
        docker exec -it $1 mysql -u root -p1121 -e "grant select,replication slave,replication client on *.* to 'slave'@'%' identified by \"1121\";flush privileges;"

        docker exec -it $2 mysql -u root -p1121 -e "change master to master_host='$1',master_port=3306,master_user='slave',master_password='1121',master_log_file='$LOG_FILE_NAME', master_log_pos=$LOG_FILE_POS,master_connect_retry=30;start slave;"
    fi
}

link $name-master $name-slave-1
link $name-slave-1 $name-slave-2

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
  docker container restart $name-slave-${id}
done

echo `date`: "完成!"
