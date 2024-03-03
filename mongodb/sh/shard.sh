#!/bin/bash

docker compose -f ../docker-compose-shard.yml up -d

sleep 15

docker exec -it shard_config_1 bash -c "echo 'rs.initiate({_id: \"configRS\",configsvr: true, members: [{ _id: 0, host: \"shard_config_1:27019\" },{ _id: 1, host: \"shard_config_2:27019\" }]})' | mongosh --port 27019"


docker exec -it shard_00_00 bash -c "echo 'rs.initiate({_id: \"shard_00\",members: [{ _id: 0, host: \"shard_00_00:27018\" },{ _id: 1, host: \"shard_00_01:27018\" }]})' | mongosh --port 27018"
docker exec -it shard_01_00 bash -c "echo 'rs.initiate({_id: \"shard_01\",members: [{ _id: 0, host: \"shard_01_00:27018\" },{ _id: 1, host: \"shard_01_01:27018\" }]})' | mongosh --port 27018"

sleep 15

docker exec -it shard_router bash -c "echo 'sh.addShard(\"shard_00/shard_00_00:27018,shard_00_01:27018\")' | mongosh --port 27017"
docker exec -it shard_router bash -c "echo 'sh.addShard(\"shard_01/shard_01_00:27018,shard_01_01:27018\")' | mongosh --port 27017"

# docker exec -it shard_router mongosh --port 27017
# sh.shardCollection("test.testc", { _id: "hashed" } )
# for(i=0; i<1000;i++) {db.testc.insertOne({_id: i, "name": "User_" + i});}
# db.testc.find().count()

# docker exec -it shard_00_00 mongosh --port 27018
# db.testc.countDocuments()