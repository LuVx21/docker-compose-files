# sudo curl -L "https://github.com/docker/compose/releases/download/v2.6.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo curl -L "https://get.daocloud.io/docker/compose/releases/download/v2.6.0/docker-compose-`uname -s`-`uname -m`" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose --version

# -------------------------------

docker run -itd --name rustpad \
-p 3030:3030 ekzhang/rustpad

docker run -itd --name centos \
-p 8080:80 \
-p 8888:8888 -\
-privileged=true --restart=always centos:centos7

docker run -d --name pichome \
-p 80:80 -\
-privileged=true --restart=always -v ~/docker/pichome:/var/www/html oaooa/pichome
