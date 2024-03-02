#!/bin/bash

mkdir -p $HOME/docker/mongo/mongo_{1,2,3}/{data,configdb}

openssl rand -base64 756 > mongodb.key
chmod 400 mongodb.key
# mv mongodb.key $HOME/docker/mongo/mongo_{1,2,3}
mv mongodb.key $HOME/docker/mongo

docker exec -it rs_mongo_1 mongosh "mongodb://admin:1121@localhost:27017/admin"

# rs.initiate({
#     _id: "rs0",
#     members: [
#         { _id : 0, host : "mini.rx:37017" },
#         { _id : 1, host : "mini.rx:37018" },
#         { _id : 2, host : "mini.rx:37019" }
#     ]
# });
