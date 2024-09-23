#!/bin/bash

curl https://raw.githubusercontent.com/alibaba/Sentinel/master/sentinel-dashboard/Dockerfile > ./sentinel-dashboard/Dockerfile
cd sentinel-dashboard && sed -i "" 's/1.8.6/1.8.8/g' Dockerfile && sed -i "" 's/amd64\///g' Dockerfile \
&& docker buildx build -t luvx/sentinel-dashboard:latest -t luvx/sentinel-dashboard:1.8.8 --platform linux/amd64,linux/arm64 . --push

git clone --depth=1 https://github.com/chartdb/chartdb
cd chartdb && docker buildx build -t luvx/chartdb --platform linux/amd64,linux/arm64 . --push

git clone --depth=1 https://github.com/zyx0814/Pichome-docker pichome
cd pichome && docker buildx build -t luvx/pichome:latest -t luvx/pichome:2.0 --platform linux/amd64,linux/arm64 . --push
