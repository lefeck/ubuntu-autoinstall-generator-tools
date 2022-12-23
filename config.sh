#!/bin/bash
#
sed -i '/^bind-address/c\port = 13306' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i '/^#key_buffer_size/c\key_buffer_size = 128M' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i '/^#max_allowed_packet/c\max_allowed_packet = 1G' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i '/^#thread_stack/c\thread_stack = 512K' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i '/^#thread_cache_size/c\thread_cache_size = 16' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i '/^#max_connections/c\max_connections = 2000' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i '/^#slow_query_log_file/c\slow_query_log_file    = /var/log/mysql/mariadb-slow.log' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i '/^#long_query_time/c\long_query_time        = 10' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i '/^#log_slow_verbosity/c\log_slow_verbosity     = query_plan,explain' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i '/^#log-queries-not-using-rndexes/c\log-queries-not-using-rndexes' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i '/^#min_examined_row_limit/c\min_examined_row_limit = 1000' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i '/^#table_cache/c\table_cache = 128' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i '/^#skip-name-resolvlse/c\skip-name-resolve' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i '/^#thread_cache_size/c\thread_cache_size = 32' /etc/mysql/mariadb.conf.d/50-server.cnf