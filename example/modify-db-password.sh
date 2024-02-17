#!/bin/bash

# This script will be executed *after* all the other init scripts.
# You can put your own initialization stuff in here if you don't
# want to do the full Sys V style init stuff.

# the following functions are used for logging purposes and are not recommended to be modified
# set extraiable value
DATE=`date "+%Y-%m-%d %H:%M:%S"`
USER=`whoami`
HOST_NAME=`hostname`
LOG_FILE="/var/log/record-db.log"

# Execution successful log printing path
function log_info () {
    echo "${DATE} ${HOST_NAME} ${USER} execute $0 [INFO] $@" >> ${LOG_FILE}
}

# Execution successful ⚠️ warning log print path
function log_warn () {
    echo "${DATE} ${HOST_NAME} ${USER} execute $0 [WARN] $@" >> ${LOG_FILE}
}

# Execution failure log print path
function log_error () {
    echo -e "\033[41;37m ${DATE} ${HOST_NAME} ${USER} execute $0 [ERROR] $@ \033[0m"  >> ${LOG_FILE}
}

function fn_log ()  {
    if [  $? -eq 0  ]
    then
            log_info "👍 $@ sucessed."
            echo -e "\033[32m $@ sucessed. \033[0m"
    else
            log_error "👿 $@ failed."
            echo -e "\033[41;37m $@ failed. \033[0m"
            exit 1
    fi
}

# this is an example of password mysql change
mysql_user="root"
# default password is null
mysql_password="123456"
new_mysql_password="Mspx@2001"
while true; do
    processNum=`ps aux | grep mysql | grep -v grep | wc -l`;
    # change mysql password
    if [ $processNum -ne 0 ]; then
      log_info "waiting for 2s"
      sleep 2
      # importing database tables
      sudo mysql -u${mysql_user} -p${mysql_password}  << EOF
      GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY "${new_mysql_password}" WITH GRANT OPTION;
      GRANT ALL ON *.* TO 'root'@'127.0.0.1' IDENTIFIED BY "${new_mysql_password}" WITH GRANT OPTION;
      GRANT ALL ON *.* TO 'root'@'localhost' IDENTIFIED BY "${new_mysql_password}" WITH GRANT OPTION;
      FLUSH PRIVILEGES;
      COMMIT;
EOF
      fn_log "Update mysql password"
      break
    else
      sleep 2
      log_info "waiting for 2s"
    fi
done
exit 0