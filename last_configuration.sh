#!/bin/bash
#Written by mr-anderson86, Dec 2019

source env.sh

sed -i 's/#security/security/' /etc/mongod.conf
sed -i 's/#authorization/authorization/' /etc/mongod.conf
sed -i 's/#keyFile/keyFile/' /etc/mongod.conf

systemctl restart mongod
check_status $? "restart service mongod"
