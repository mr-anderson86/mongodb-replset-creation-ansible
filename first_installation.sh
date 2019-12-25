#!/bin/bash
#Written by mr-anderson86, Dec 2019
source env.sh

cp mongodb-org-4.2.repo /etc/yum.repos.d/
#This installs both mongodb-org-server and mongodb-org-shell and other mongodb tools
yum install mongodb-org -y
check_status $? "mongodb-org installation"
mongod --version

mkdir -p ${DB_PATH} ; chown mongod:mongod -R ${DB_PATH}
mkdir -p ${LOG_DIR} ; chown mongod:mongod -R ${LOG_DIR}
chown mongod:mongod -R /var/lib/mongo
touch /var/run/mongodb/mongod.pid; chown mongod:mongod -R /var/run/mongodb

iptables -A INPUT -m state --state NEW -p tcp --dport ${DB_PORT} -j ACCEPT
check_status $? "Open port ${DB_PORT}"

cp /etc/mongod.conf /etc/mongod.conf.bkp -f
cp mongod.conf /etc/ -f
sed -i "s#LOG_DIR#${LOG_DIR}#g" /etc/mongod.conf
sed -i "s#DB_PATH#${DB_PATH}#g" /etc/mongod.conf
sed -i "s#BIND_IP#${BIND_IP}#g" /etc/mongod.conf
sed -i "s#DB_PORT#${DB_PORT}#g" /etc/mongod.conf
sed -i "s#REPSET_NAME#${REPSET_NAME}#g" /etc/mongod.conf

systemctl restart mongod
check_status $? "restart service mongod"
