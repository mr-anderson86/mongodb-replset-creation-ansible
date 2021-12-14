# MongoDB Replica Set Creation

## Description

This Ansible playbook is used for setting up a new replica set in MongoDB.  
(Written by mr-anderson86)

## Table of Contents

1. [Main actions](#main-actions)
2. [Notes](#notes)
3. [Prerequisites](#prerequisites)
4. [Usage](#usage)
5. [Verify all is OK](#verify-all-is-ok)
    * [Verify replica set and admin user](#verify-replica-set-and-admin-user)
    * [Verify regular DB and user](#verify-regular-db-and-user)

### Main actions:
* Installes MongoDB server and shell (org) on all servers
* Creates the replica set between all members (servers)
* Creates admin user (under db 'admin')
* Creates regular user (under db "$DB_NAME")

### Notes:
* The mongod service will run on the same port on all servers.
* The same DB path and log dir will be used on all servers.
* The above are configured via [env.yaml](env.yaml) file (see [usage](#usage) below)

### Prerequisites
1. It runs only on CentOS machines (probably will work also on RedHat)
2. You must have root, on all members!
3. Make sure all users can ssh without password from one to another (from root to root).  
So if needed, generate ssh keys and put the public keys unser ~/.ssh/authorized_keys in all servers.
4. And of course: make sure to have Ansible installed wherever you are runinng the playbook from ;-)

### Usage
After that, usage is pretty simple (Run it on your Ansible machine):
```bash
git clone https://github.com/mr-anderson86/mongodb-replset-creation-ansible.git
cd mongodb-replset-creation-ansible
vi env.yaml
# Edit all your details such as:
# * Port for MongoDB (defailt is 27017)
# * Replica set name (REPSET_NAME)
# * Members - all seperated with space, in 1 string (don't put the port number)
# * Admin username/password
# * Regular user username/password
# * Regular DB name (outside of 'admin' DB)
# * DB path and log dir
#
# Note that the same configuruation will be for all of your members (servers)

vi hosts
# Under "all_servers", edit your hosts names or IP addresses (must be the same as "MEMBERS" in env.yaml)
# Under "main_server", put one of your members, doesn't matter which of them

ansible-playbook -i hosts -e @env.yaml repset_creation_playbook.yaml -vv
```

### Verify all is OK:

#### Verify replica set and admin user
Assuming that:
* replica set name: 'my-repset'
* admin user/pass: admin/Admin123
* members: vm1 and vm2 (default port)
```bash
mongo "mongodb://vm1:27017,vm2:27017/admin?replicaSet=my-repset" --username "admin" --password "Admin123"
//verify you are connected OK
db.runCommand({connectionStatus: 1})
//verify replica set is OK
rs.status()
//verify admin user is OK
db.getUser('admin')
```

#### Verify regular DB and user
Assuming that:
* replica set name: 'my-repset'
* regular user/pass: myuser/Password123
* members: vm1 and vm2 (default port)
* DB name: mydb
```bash
mongo "mongodb://vm1:27017,vm2:27017/mydb?replicaSet=my-repset" --username "myuser" --password "Password123"
//verify you are connected OK
db.runCommand({connectionStatus: 1})
//verify regular user is OK
db.getUser('myuser')
```

### The end. Enjoy :-)
