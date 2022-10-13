<details>
<summary>点击展开目录</summary>
<!-- TOC -->

    - [docker-compose](#docker-compose)
        - [配置](#配置)
- [](#)
    - [rockermq](#rockermq)

<!-- /TOC -->
</details>


```json
{
  "registry-mirrors": [
    "https://wfe8hnnf.mirror.aliyuncs.com",
    "https://mirror.baidubce.com",
    "https://hub-mirror.c.163.com"
  ]
}
```

## docker-compose

```bash
# sudo curl -L "https://github.com/docker/compose/releases/download/v2.6.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo curl -L "https://get.daocloud.io/docker/compose/releases/download/v2.6.0/docker-compose-`uname -s`-`uname -m`" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose --version
```


### 配置

如果要在其他容器里直接使用kafka容器, 可以将它们加入同一个network

```bash
docker network create nginx-proxy
```

在各自容器的docker-compose.yml加入network配置, 如下

```yml
networks:
  default:
    external:
      name: nginx-proxy
```


##

```bash
docker run -itd --name showdoc --user=root --privileged=true -p 80:80 -v ~/showdoc_data/html:/var/www/html/ star7th/showdoc
docker run -itd --name neo4j --publish=7474:7474 --publish=7687:7687 --volume=$HOME/neo4j/data:/data neo4j

docker run -itd --name code-server \
  -p 8080:8080 \
  -v "$HOME/code:/home/coder/project" \
  -v "$HOME/.config:/home/coder/.config" \
  -u "$(id -u):$(id -g)" \
  -e "DOCKER_USER=$USER" \
  -e "PASSWORD=<pwd>" \
  codercom/code-server


docker run -itd --name rustpad \
-p 3030:3030 \
ekzhang/rustpad

docker run -itd --name centos \
-p 8080:80 \
-p 8888:8888 \
--privileged=true --restart=always \
centos:centos7

docker run -itd --name pichome \
-p 80:80 \
--privileged=true --restart=always -v ~/docker/pichome:/var/www/html \
oaooa/pichome

```


```bash
docker run -itd --name jupyter-notebook \
-p 58081:8888 \
-u "$(id -u):$(id -g)" \
# -v $HOME/docker/jupyter:/home/jovyan/work \
jupyter/base-notebook
# start-notebook.sh \
# --NotebookApp.password='sha1:874c990621e5:e47fda27460f59ca2930a4866bcd580aceb1bb44'

docker run -itd --name jupyter-notebook \
-p 58081:8888 \
-e GRANT_SUDO=yes \
-e RESTARTABLE=yes \
--user root \
--mount source=jupyter-workspace,destination=/home/jovyan/work \
jupyter/scipy-notebook
```

## appsmith

```bash
docker run -d --name appsmith \
-p 50080:80 \
-v "~/docker/appsmith:/appsmith-stacks" \
--pull always appsmith/appsmith-ce
```


## rockermq

```bash
docker volume create rocketmq_data

docker run -itd --name rocketmq \
 --hostname rocketmq \
 --restart=always \
 -p 18080:8080 \
 -p 59876:9876 \
 -p 50909:10909 \
 -p 50911:10911 \
 -p 50912:10912 \
 -v rocketmq_data:/home/app/data \
 -v /etc/localtime:/etc/localtime \
 -v /var/run/docker.sock:/var/run/docker.sock \
 xuchengen/rocketmq:latest
```

## nacos

```bash
mkdir -p ~/docker/nacos/init.d ~/docker/nacos/logs
echo 'management.endpoints.web.exposure.include=*' > ~/docker/nacos/init.d/custom.properties

# mysql: create database nacos_config;

docker run -d -p 8848:8848  \
-e MODE=standalone \
-e PREFER_HOST_MODE=hostname \
-e SPRING_DATASOURCE_PLATFORM=mysql \
-e MYSQL_SERVICE_HOST=127.0.0.1 \
-e MYSQL_SERVICE_PORT=53306 \
-e MYSQL_SERVICE_DB_NAME=nacos_config \
-e MYSQL_SERVICE_USER=root \
-e MYSQL_SERVICE_PASSWORD=**** \
-e MYSQL_SERVICE_DB_PARAM="characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useSSL=false&serverTimezone=UTC" \
-e MYSQL_DATABASE_NUM=1 \
-v ~/docker/nacos/init.d/custom.properties:/home/nacos/init.d/custom.properties \
-v ~/docker/nacos/logs:/home/nacos/logs \
--restart always --name nacos nacos/nacos-server
```