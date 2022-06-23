<details>
<summary>点击展开目录</summary>
<!-- TOC -->
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
