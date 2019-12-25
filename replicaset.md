# MongoDB create replicaset cluster

## Description:

Here I'll provide steps on how to create a repicaset cluster for MongoDB.  

### Final otput:
* Mongo DB on an Ubuntu server, which contains data from Twitter.
* A command which queries the DB to get the usernames.

## Main steps:

* Install MongoDB on all of your servers.
* First configuration: files and replSet.
* Generate a key file and copy to all servers.
* Create admin user for the replSet on all DBs.
* Re-edit the /etc/mongod.conf file to enable authorization.
* Restart MongoDB service on all servers.

### Install MongoDB on the server.
1. On each server, install MongoDB (need root/sudo):
```bash
# Ubuntu
apt-get install -y mongodb-org
# Redhat/CentOS
yum install -y mongodb-org

# Of course, if you want to use spesific mongo version, like mongo-server-org 4.2.1, search on Google where can you get it fro,.

# Verifying installation
mongod --version
# Output for example:
# db version v4.2.1
```

### First configuration: files and replSet.
1. On all servers, edit the /etc/mongod.conf file to be part of the replSet, use the file here.  
but comment the security and auth lines for now.
```bash
vi /etc/mongod.conf
# Edit your file, and save and exit.
```
2. After that, you need to fix some permissions on some dirs and files (on all servers).  
Then, restart the mongodb service (on all servers).
```bash
touch .../pid
chown mongod:mongo -R /var/lib/...
service mongod restart
```
3. Create the replica set to contain all of your servers
```bash
mongo --host localhost
config = {

}
re.create(config)
rs.status()
exit
```


### The end, enjoy :)
