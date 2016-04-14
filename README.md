mysql-replica
-------------

### build image
```sh
docker build -f Dockerfile -t xidui/mysql .
```

### start a master
```sh
docker run --name mysql-master \
           -e MASTER=true \
           -e MYSQL_ROOT_PASSWORD=your_pass \ # this env is optional
           -d noj/mysql
```

### start a slave
```sh
docker run --name mysql-slave-1 \
           -e SLAVE=<server_id> \
           -e BACKUP_USER=<backup_user> \
           -e BACKUP_PASS=<backup_pass> \
           -e MASTER_HOST=<master_host_address> \
           -e MYSQL_ROOT_PASSWORD=your_pass \ # this env is optional
           -d noj/mysql
```


### notes
* the default root password is `your_pass`, remember to change it if you want to put it into producetion environment or you can specify root password into docker container when starting.
* server id for slave can be any number greater than 1(which master occupies).
