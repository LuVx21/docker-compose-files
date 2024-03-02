#!/bin/bash

docker exec -it shard_config bash -c "echo 'rs.initiate({_id: \"configRS\",configsvr: true, members: [{ _id : 0, host : \"shard_config:27019\" }]})' | mongosh --port 27019"


docker exec -it shard_rs00 bash -c "echo 'rs.initiate({_id: \"RS0\",members: [{ _id : 0, host : \"shard_rs00:27018\" },{ _id : 1, host : \"shard_rs01:27018\" }]})' | mongosh --port 27018"
docker exec -it shard_rs10 bash -c "echo 'rs.initiate({_id: \"RS1\",members: [{ _id : 0, host : \"shard_rs10:27018\" },{ _id : 1, host : \"shard_rs11:27018\" }]})' | mongosh --port 27018"

sleep 5

docker exec -it shard_mongos bash -c "echo 'sh.addShard(\"RS0/shard_rs00:27018,shard_rs01:27018\")' | mongosh --port 27017"
docker exec -it shard_mongos bash -c "echo 'sh.addShard(\"RS1/shard_rs10:27018,shard_rs11:27018\")' | mongosh --port 27017"

# docker exec -it shard_mongos mongosh --port 27017
# sh.shardCollection("test.testc", { _id : "hashed" } )
# for(i=0; i<1000;i++) {db.testc.insertOne({_id: i, "name": "User_" + i});}
# db.testc.find().count()

# docker exec -it shard_rs00 mongosh --port 27018
# db.testc.countDocuments()