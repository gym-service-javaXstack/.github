#!/bin/bash

echo "########### Waiting for mongodb1 ###########"
until mongosh --host mongodb1:27017 -u mongodb -p mongodb --eval "printjson(db.runCommand({ serverStatus: 1}).ok)"
  do
    echo "########### Sleeping  ###########"
    sleep 5
  done

echo "########### Waiting for mongodb2 ###########"
until mongosh --host mongodb2:27018 -u mongodb -p mongodb --eval "printjson(db.runCommand({ serverStatus: 1}).ok)"
  do
    echo "########### Sleeping  ###########"
    sleep 5
  done
echo "########### All replicas are ready!!!  ###########"


echo "########### Setting up cluster config  ###########"

echo "########### Initiating replica set ###########"
cd /
echo '
try {
  var config = {
    "_id": "rs0",
    "version": 1,
    "members": [
      {"_id": 0, "host": "mongodb1:27017" },
      {"_id": 1, "host": "mongodb2:27018" }
    ]
  };
  rs.initiate(config, { force: true});
  rs.status();
} catch (e) {
  rs.status();
}
' > /mongo-rs-config.js

sleep 10
echo "########### mongodb1 /mongo-rs-config.js ###########"
mongosh -u mongodb -p mongodb --host mongodb1:27017 /mongo-rs-config.js


echo "########### Getting mongodb1 status  ###########"
mongosh --host  mongodb1:27017 -u mongodb -p mongodb <<EOF
rs.status()
EOF

echo "########### Getting mongodb2 status  ###########"
mongosh --host  mongodb2:27018 -u mongodb -p mongodb <<EOF
rs.status()
EOF