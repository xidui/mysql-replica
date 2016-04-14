#!/bin/bash

change_root_pass() {
    mysql -uroot -pyour_pass -e"UPDATE mysql.user SET password=PASSWORD("$MYSQL_ROOT_PASSWORD") WHERE User='root';"
    mysql -uroot -pyour_pass -e"FLUSH PRIVILEGES;"
}

loop() {
    while((1));
    do
        sleep 10;
    done;
}

deploy_master() {
    echo "deploy master"
    # change the default ip address to bind at 0.0.0.0
    sed -i -e "s|bind-address.*$|bind-address\t= 0.0.0.0|" /etc/mysql/my.cnf

    # change server_id
    sed -i -e "s|#server-id.*$|server-id\t= 1|" /etc/mysql/my.cnf

    # change log_bin
    sed -i -e "s|#log_bin.*$|log_bin\t= /var/log/mysql/mysql-bin.log|" /etc/mysql/my.cnf

    service mysql start
    # grant privileges
    mysql -uroot -pyour_pass -e"GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'your_pass' WITH GRANT OPTION;"
    mysql -uroot -pyour_pass -e"FLUSH PRIVILEGES;"

    if [ ! -z "$MYSQL_ROOT_PASSWORD" ]; then
        change_root_pass
    fi
    loop
}

deploy_slave() {
    echo "deploy slave"
    if [ -z $BACKUP_USER -o -z $BACKUP_PASS -o -z $MASTER_HOST ]; then
        echo >&2 'You need to specify BACKUP_USER, BACKUP_PASS and MASTER_HOST'
        exit 1
    fi

    # change the default ip address to bind at 0.0.0.0
    sed -i -e "s|bind-address.*$|bind-address\t= 0.0.0.0|" /etc/mysql/my.cnf

    # change server_id
    sed -i -e "s|#server-id.*$|server-id\t= $SLAVE|" /etc/mysql/my.cnf

    # change log_bin to relay_log
    sed -i -e "s|#log_bin.*$|relay_log\t= /var/log/mysql/mysql-relay-bin|" /etc/mysql/my.cnf

    service mysql start
    # config slave
    mysql -uroot -pyour_pass -e"CHANGE MASTER TO MASTER_HOST='$MASTER_HOST', MASTER_USER='$BACKUP_USER', MASTER_PASSWORD='$BACKUP_PASS', MASTER_LOG_FILE='mysql-bin.000001', MASTER_LOG_POS=0;"
    mysql -uroot -pyour_pass -e"START SLAVE;"

    if [ ! -z "$MYSQL_ROOT_PASSWORD" ]; then
        change_root_pass
    fi
    loop
}

if [ $1 = 'mysqld' ]; then
    if [ ! -z $MASTER ]; then
        deploy_master
    fi

    if [ ! -z $SLAVE ]; then
        deploy_slave
    fi
else
    exec "$@"
fi
