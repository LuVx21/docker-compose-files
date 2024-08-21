#!/bin/bash

curl https://raw.githubusercontent.com/alibaba/Sentinel/master/sentinel-dashboard/Dockerfile > ./sentinel-dashboard/Dockerfile
cd sentinel-dashboard && sed -i "" 's/1.8.6/1.8.8/g' Dockerfile && docker buildx build -t luvx/sentinel-dashboard:latest --platform linux/amd64,linux/arm64 . --push
