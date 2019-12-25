#!/bin/bash
#Written by mr-anderson86, Dec 2019

source env.sh
CONFIG="{ _id: \"${REPSET_NAME}\", members: ["

i=0
for vm in $MEMBERS; do
  member="{ _id: $i, host: \"${vm}:${DB_PORT}\" }"
  CONFIG="${CONFIG} ${member},"
  i=`expr $i + 1`
done
CONFIG="`echo ${CONFIG} | sed 's/.$/]/'` }"

ADM_USER="{ user: \"${ADMIN_USER}\",
            pwd: \"${ADMIN_PASS}\",
            roles: [{role: \"userAdminAnyDatabase\", db: \"admin\" }, \"readWriteAnyDataBase\" ]
          }"

REGULAR_USER="{ user: \"${DB_USER}\",
                pwd: \"${DB_PASS}\",
                roles: [{\"role\": \"readWrite\", \"db\": \"${DB_NAME}\" } ]
              }"


mongo "${BIND_IP}:${DB_PORT}" --eval "db=db.getSiblingDB('admin');
print(db);
var config = $CONFIG;
printjson(config);
rs.initiate(config);
re.status();"
check_status $? "Repset ${REPSET_NAME} creation"
echo;echo

mongo "${BIND_IP}:${DB_PORT}" --eval "db=db.getSiblingDB('admin');
print(db);
var adm_user = $ADM_USER;
printjson(adm_user);
db.createUser(adm_user);
var adm_username = '$ADMIN_USER';
db.grantRolesToUser(adm_username, [ {role: 'root', db: 'admin'} ] );"
check_status $? "Admin user creation"
echo;echo

mongo "${BIND_IP}:${DB_PORT}" --eval "var db_name = '$DB_NAME';
db=db.getSiblingDB(db_name);
print(db);
var reular_user = $REGULAR_USER;
printjson(reular_user);
db.createUser(reular_user);"
check_status $? "Regular user creation"
echo;echo


openssl rand -base64 756 > /var/lib/mongo/mongdo.key
check_status $? "Keyfile creation"
chmod 400 /var/lib/mongo/mongdo.key
chown mongod:mongod /var/lib/mongo/mongdo.key
for member in $MEMBERS ; do 
	rsync -av /var/lib/mongo/mongdo.key ${member}:/var/lib/mongo/mongdo.key
	check_status $? "Copy keyfile to ${member}"
done
