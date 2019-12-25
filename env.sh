#!/bin/bash

export LOG_DIR=/var/log/mongodb
export DB_PATH=/var/lib/mongo
export BIND_IP=`hostname`
export DB_PORT=27017
export REPSET_NAME=my-repset
export MEMBERS="some-host1 some-host2 some-host3"
export ADMIN_USER=admin
export ADMIN_PASS=Admin123
export DB_USER=dbuser
export DB_PASS=dbuser123
export DB_NAME=mydb

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
		info_msg "${MSG} finished successfully"
	fi
}
