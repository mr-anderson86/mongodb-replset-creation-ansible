#!/bin/bash
#Written by mr-anderson86, Dec 2019

info_msg()
{
    echo "[`date | awk '{print $4}'` INFO] $1"
}
error_msg()
{
    echo "[`date | awk '{print $4}'` ERROR] $1"
}
debug_msg()
{
    echo "[`date | awk '{print $4}'` DEBUG] $1"
}
check_status()
{
    RC=$1
    MSG=$2
    if [[ $RC -ne 0 ]]; then
        error_msg "${MSG} failed."
        exit $RC
    else
        info_msg "${MSG} finished successfully."
    fi
}

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
var result = rs.initiate(config);
printjson(result);
rs.status();
quit(rs.status().ok - 1)"
check_status $? "Repset ${REPSET_NAME} creation"
echo;echo

members=`echo "${MEMBERS}:${DB_PORT}" | sed "s/ /:${DB_PORT},/g"`
mongo "mongodb://${members}/admin?replicaSet=${REPSET_NAME}" --eval "print(db);
var adm_user = $ADM_USER;
var adm_username = '$ADMIN_USER';
printjson(adm_user);
is_user = db.getUser(adm_username);
if (is_user == null) {
db.createUser(adm_user);
db.grantRolesToUser(adm_username, [ {role: 'root', db: 'admin'} ] );
} else {
print('Admin user already exists')
};
"
check_status $? "Admin user creation"
echo;echo

mongo "mongodb://${members}/${DB_NAME}?replicaSet=${REPSET_NAME}" --eval "var db_name = 'print(db);
var regular_user = $REGULAR_USER;
var regular_username = '$DB_USER';
printjson(reular_user);
is_user = db.getUser(regular_username);
if (is_user == null) {
db.createUser(reular_user);
} else {
print('Regular user already exists');
}"
check_status $? "Regular user creation"
echo;echo

openssl rand -base64 756 > ${DB_PATH}/mongod.key
check_status $? "Keyfile creation"
chmod 400 ${DB_PATH}/mongod.key
chown mongod:mongod ${DB_PATH}/mongod.key
for member in $MEMBERS ; do 
	rsync -av ${DB_PATH}/mongod.key ${member}:${DB_PATH}/mongod.key
	check_status $? "Copy keyfile to ${member}"
done