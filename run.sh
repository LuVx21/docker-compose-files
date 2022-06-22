


docker run -itd --name rustpad \
-p 3030:3030 ekzhang/rustpad

docker run -itd --name centos \
-p 8080:80 \
-p 8888:8888 -\
-privileged=true --restart=always centos:centos7

docker run -d --name pichome \
-p 80:80 -\
-privileged=true --restart=always -v ~/docker/pichome:/var/www/html oaooa/pichome
