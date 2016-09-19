/opt2/mysql$ docker run --name mysql1 -e MYSQL_ROOT_PASSWORD=mysql1pass -e MYSQL_DATABASE=mydata -dit -p 33061:3306 -v /opt2/mysql/server1/conf.d:/etc/mysql/mysql.conf.d/   -v /opt2/mysql/server1/data:/var/lib/mysql -v /opt2/mysql/server1/log:/var/log/mysql -v /opt2/mysql/server1/backup:/backup -h  mysql1 mysql
89d03e7bdb46896bbdb5a7c93e73eb6a8b200d9946da041951827650c5e3295f
/opt2/mysql$ docker exec -ti mysql1 sh  -c "mysql -uroot -p"
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 2
Server version: 5.7.14-log MySQL Community Server (GPL)

Copyright (c) 2000, 2016, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> source /backup/initdb.sql
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
Query OK, 0 rows affected (0.00 sec)

Query OK, 0 rows affected (0.01 sec)

Query OK, 0 rows affected (0.00 sec)

+------------------+----------+--------------+------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+----------+--------------+------------------+-------------------+
| mysql-bin.000003 |      154 | mydata       |                  |                   |
+------------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)

+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| server_id     | 101   |
+---------------+-------+
1 row in set (0.00 sec)

mysql> ^DBye
/opt2/mysql$ docker run --name mysql2  --link mysql1 -e MYSQL_ROOT_PASSWORD=mysql2pass -e MYSQL_DATABASE=mydata -dit -p 33062:3306 -v /opt2/mysql/server2/conf.d:/etc/mysql/mysql.conf.d/   -v /opt2/mysql/server2/data:/var/lib/mysql -v /opt2/mysql/server2/log:/var/log/mysql -v /opt2/mysql/server2/backup:/backup -h  mysql2 mysql
5e616fa51daf1c13524be022d0219f7ed27ed2cda1a6d72e0d505aaf72092b53
/opt2/mysql$ mysql2ip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' mysql2)
/opt2/mysql$ docker exec -i mysql1 sh -c "echo '$mysql2ip mysql2 mysql2' >> /etc/hosts"
/opt2/mysql$ docker exec -i mysql1 sh -c "cat /etc/hosts"
127.0.0.1       localhost
::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
172.17.0.2      mysql1
172.17.0.3 mysql2 mysql2
/opt2/mysql$ docker exec -ti mysql2 sh -c "ping mysql1"
PING mysql1 (172.17.0.2): 56 data bytes
64 bytes from 172.17.0.2: icmp_seq=0 ttl=64 time=0.130 ms
64 bytes from 172.17.0.2: icmp_seq=1 ttl=64 time=0.170 ms
64 bytes from 172.17.0.2: icmp_seq=2 ttl=64 time=0.170 ms
^C--- mysql1 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max/stddev = 0.130/0.157/0.170/0.000 ms
/opt2/mysql$ docker exec -ti mysql1 sh -c "ping mysql2"
PING mysql2 (172.17.0.3): 56 data bytes
64 bytes from 172.17.0.3: icmp_seq=0 ttl=64 time=0.144 ms
64 bytes from 172.17.0.3: icmp_seq=1 ttl=64 time=0.141 ms
64 bytes from 172.17.0.3: icmp_seq=2 ttl=64 time=0.173 ms
64 bytes from 172.17.0.3: icmp_seq=3 ttl=64 time=0.087 ms
^C--- mysql2 ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max/stddev = 0.087/0.136/0.173/0.031 ms
/opt2/mysql$ docker exec -ti mysql2 sh  -c "mysql -uroot -p"
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 2
Server version: 5.7.14-log MySQL Community Server (GPL)
mysql> source /backup/initdb.sql
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
Query OK, 0 rows affected (0.00 sec)

Query OK, 0 rows affected (0.00 sec)

Query OK, 0 rows affected (0.00 sec)

+------------------+----------+--------------+------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+----------+--------------+------------------+-------------------+
| mysql-bin.000003 |      154 | mydata       |                  |                   |
+------------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)

+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| server_id     | 102   |
+---------------+-------+
1 row in set (0.01 sec)

mysql> stop slave;
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> CHANGE MASTER TO MASTER_HOST = 'mysql1', MASTER_USER = 'replicator', MASTER_PASSWORD = 'repl1234or', MASTER_LOG_FILE = 'mysql-bin.000003', MASTER_LOG_POS = 154;
Query OK, 0 rows affected, 2 warnings (0.04 sec)

mysql> show slave status;
+----------------+-------------+-------------+-------------+---------------+------------------+---------------------+-------------------------+---------------+-----------------------+------------------+-------------------+-----------------+---------------------+--------------------+------------------------+-------------------------+-----------------------------+------------+------------+--------------+---------------------+-----------------+-----------------+----------------+---------------+--------------------+--------------------+--------------------+-----------------+-------------------+----------------+-----------------------+-------------------------------+---------------+---------------+----------------+----------------+-----------------------------+------------------+-------------+----------------------------+-----------+---------------------+-------------------------+--------------------+-------------+-------------------------+--------------------------+----------------+--------------------+--------------------+-------------------+---------------+----------------------+--------------+--------------------+
| Slave_IO_State | Master_Host | Master_User | Master_Port | Connect_Retry | Master_Log_File  | Read_Master_Log_Pos | Relay_Log_File          | Relay_Log_Pos | Relay_Master_Log_File | Slave_IO_Running | Slave_SQL_Running | Replicate_Do_DB | Replicate_Ignore_DB | Replicate_Do_Table | Replicate_Ignore_Table | Replicate_Wild_Do_Table | Replicate_Wild_Ignore_Table | Last_Errno | Last_Error | Skip_Counter | Exec_Master_Log_Pos | Relay_Log_Space | Until_Condition | Until_Log_File | Until_Log_Pos | Master_SSL_Allowed | Master_SSL_CA_File | Master_SSL_CA_Path | Master_SSL_Cert | Master_SSL_Cipher | Master_SSL_Key | Seconds_Behind_Master | Master_SSL_Verify_Server_Cert | Last_IO_Errno | Last_IO_Error | Last_SQL_Errno | Last_SQL_Error | Replicate_Ignore_Server_Ids | Master_Server_Id | Master_UUID | Master_Info_File           | SQL_Delay | SQL_Remaining_Delay | Slave_SQL_Running_State | Master_Retry_Count | Master_Bind | Last_IO_Error_Timestamp | Last_SQL_Error_Timestamp | Master_SSL_Crl | Master_SSL_Crlpath | Retrieved_Gtid_Set | Executed_Gtid_Set | Auto_Position | Replicate_Rewrite_DB | Channel_Name | Master_TLS_Version |
+----------------+-------------+-------------+-------------+---------------+------------------+---------------------+-------------------------+---------------+-----------------------+------------------+-------------------+-----------------+---------------------+--------------------+------------------------+-------------------------+-----------------------------+------------+------------+--------------+---------------------+-----------------+-----------------+----------------+---------------+--------------------+--------------------+--------------------+-----------------+-------------------+----------------+-----------------------+-------------------------------+---------------+---------------+----------------+----------------+-----------------------------+------------------+-------------+----------------------------+-----------+---------------------+-------------------------+--------------------+-------------+-------------------------+--------------------------+----------------+--------------------+--------------------+-------------------+---------------+----------------------+--------------+--------------------+
|                | mysql1      | replicator  |        3306 |            60 | mysql-bin.000003 |                 154 | mysql2-relay-bin.000001 |             4 | mysql-bin.000003      | No               | No                |                 |                     |                    |                        |                         |                             |          0 |            |            0 |                 154 |             154 | None            |                |             0 | No                 |                    |                    |                 |                   |                |                  NULL | No                            |             0 |               |              0 |                |                             |                0 |             | /var/lib/mysql/master.info |         0 |                NULL |                         |              86400 |             |                         |                          |                |                    |                    |                   |             0 |                      |              |                    |
+----------------+-------------+-------------+-------------+---------------+------------------+---------------------+-------------------------+---------------+-----------------------+------------------+-------------------+-----------------+---------------------+--------------------+------------------------+-------------------------+-----------------------------+------------+------------+--------------+---------------------+-----------------+-----------------+----------------+---------------+--------------------+--------------------+--------------------+-----------------+-------------------+----------------+-----------------------+-------------------------------+---------------+---------------+----------------+----------------+-----------------------------+------------------+-------------+----------------------------+-----------+---------------------+-------------------------+--------------------+-------------+-------------------------+--------------------------+----------------+--------------------+--------------------+-------------------+---------------+----------------------+--------------+--------------------+
1 row in set (0.00 sec)

mysql> ^DBye
/opt2/mysql$ docker exec -ti mysql1 sh  -c "mysql -uroot -p"
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 4
Server version: 5.7.14-log MySQL Community Server (GPL)

Copyright (c) 2000, 2016, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> stop slave;
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> CHANGE MASTER TO MASTER_HOST = 'mysql2', MASTER_USER = 'replicator', MASTER_PASSWORD = 'repl1234or', MASTER_LOG_FILE = 'mysql-bin.000003', MASTER_LOG_POS = 154;
Query OK, 0 rows affected, 2 warnings (0.07 sec)

mysql> start slave;
Query OK, 0 rows affected (0.01 sec)

mysql> show slave status;
+----------------------+-------------+-------------+-------------+---------------+------------------+---------------------+-------------------------+---------------+-----------------------+------------------+-------------------+-----------------+---------------------+--------------------+------------------------+-------------------------+-----------------------------+------------+------------+--------------+---------------------+-----------------+-----------------+----------------+---------------+--------------------+--------------------+--------------------+-----------------+-------------------+----------------+-----------------------+-------------------------------+---------------+---------------+----------------+----------------+-----------------------------+------------------+-------------+----------------------------+-----------+---------------------+-----------------------------------------+--------------------+-------------+-------------------------+--------------------------+----------------+--------------------+--------------------+-------------------+---------------+----------------------+--------------+--------------------+
| Slave_IO_State       | Master_Host | Master_User | Master_Port | Connect_Retry | Master_Log_File  | Read_Master_Log_Pos | Relay_Log_File          | Relay_Log_Pos | Relay_Master_Log_File | Slave_IO_Running | Slave_SQL_Running | Replicate_Do_DB | Replicate_Ignore_DB | Replicate_Do_Table | Replicate_Ignore_Table | Replicate_Wild_Do_Table | Replicate_Wild_Ignore_Table | Last_Errno | Last_Error | Skip_Counter | Exec_Master_Log_Pos | Relay_Log_Space | Until_Condition | Until_Log_File | Until_Log_Pos | Master_SSL_Allowed | Master_SSL_CA_File | Master_SSL_CA_Path | Master_SSL_Cert | Master_SSL_Cipher | Master_SSL_Key | Seconds_Behind_Master | Master_SSL_Verify_Server_Cert | Last_IO_Errno | Last_IO_Error | Last_SQL_Errno | Last_SQL_Error | Replicate_Ignore_Server_Ids | Master_Server_Id | Master_UUID | Master_Info_File           | SQL_Delay | SQL_Remaining_Delay | Slave_SQL_Running_State                 | Master_Retry_Count | Master_Bind | Last_IO_Error_Timestamp | Last_SQL_Error_Timestamp | Master_SSL_Crl | Master_SSL_Crlpath | Retrieved_Gtid_Set | Executed_Gtid_Set | Auto_Position | Replicate_Rewrite_DB | Channel_Name | Master_TLS_Version |
+----------------------+-------------+-------------+-------------+---------------+------------------+---------------------+-------------------------+---------------+-----------------------+------------------+-------------------+-----------------+---------------------+--------------------+------------------------+-------------------------+-----------------------------+------------+------------+--------------+---------------------+-----------------+-----------------+----------------+---------------+--------------------+--------------------+--------------------+-----------------+-------------------+----------------+-----------------------+-------------------------------+---------------+---------------+----------------+----------------+-----------------------------+------------------+-------------+----------------------------+-----------+---------------------+-----------------------------------------+--------------------+-------------+-------------------------+--------------------------+----------------+--------------------+--------------------+-------------------+---------------+----------------------+--------------+--------------------+
| Connecting to master | mysql2      | replicator  |        3306 |            60 | mysql-bin.000003 |                 154 | mysql1-relay-bin.000001 |             4 | mysql-bin.000003      | Connecting       | Yes               |                 |                     |                    |                        |                         |                             |          0 |            |            0 |                 154 |             154 | None            |                |             0 | No                 |                    |                    |                 |                   |                |                  NULL | No                            |             0 |               |              0 |                |                             |                0 |             | /var/lib/mysql/master.info |         0 |                NULL | Waiting for the next event in relay log |              86400 |             |                         |                          |                |                    |                    |                   |             0 |                      |              |                    |
+----------------------+-------------+-------------+-------------+---------------+------------------+---------------------+-------------------------+---------------+-----------------------+------------------+-------------------+-----------------+---------------------+--------------------+------------------------+-------------------------+-----------------------------+------------+------------+--------------+---------------------+-----------------+-----------------+----------------+---------------+--------------------+--------------------+--------------------+-----------------+-------------------+----------------+-----------------------+-------------------------------+---------------+---------------+----------------+----------------+-----------------------------+------------------+-------------+----------------------------+-----------+---------------------+-----------------------------------------+--------------------+-------------+-------------------------+--------------------------+----------------+--------------------+--------------------+-------------------+---------------+----------------------+--------------+--------------------+
1 row in set (0.00 sec)

mysql> show slave status;
+----------------------------------+-------------+-------------+-------------+---------------+------------------+---------------------+-------------------------+---------------+-----------------------+------------------+-------------------+-----------------+---------------------+--------------------+------------------------+-------------------------+-----------------------------+------------+------------+--------------+---------------------+-----------------+-----------------+----------------+---------------+--------------------+--------------------+--------------------+-----------------+-------------------+----------------+-----------------------+-------------------------------+---------------+---------------+----------------+----------------+-----------------------------+------------------+--------------------------------------+----------------------------+-----------+---------------------+--------------------------------------------------------+--------------------+-------------+-------------------------+--------------------------+----------------+--------------------+--------------------+-------------------+---------------+----------------------+--------------+--------------------+
| Slave_IO_State                   | Master_Host | Master_User | Master_Port | Connect_Retry | Master_Log_File  | Read_Master_Log_Pos | Relay_Log_File          | Relay_Log_Pos | Relay_Master_Log_File | Slave_IO_Running | Slave_SQL_Running | Replicate_Do_DB | Replicate_Ignore_DB | Replicate_Do_Table | Replicate_Ignore_Table | Replicate_Wild_Do_Table | Replicate_Wild_Ignore_Table | Last_Errno | Last_Error | Skip_Counter | Exec_Master_Log_Pos | Relay_Log_Space | Until_Condition | Until_Log_File | Until_Log_Pos | Master_SSL_Allowed | Master_SSL_CA_File | Master_SSL_CA_Path | Master_SSL_Cert | Master_SSL_Cipher | Master_SSL_Key | Seconds_Behind_Master | Master_SSL_Verify_Server_Cert | Last_IO_Errno | Last_IO_Error | Last_SQL_Errno | Last_SQL_Error | Replicate_Ignore_Server_Ids | Master_Server_Id | Master_UUID                          | Master_Info_File           | SQL_Delay | SQL_Remaining_Delay | Slave_SQL_Running_State                                | Master_Retry_Count | Master_Bind | Last_IO_Error_Timestamp | Last_SQL_Error_Timestamp | Master_SSL_Crl | Master_SSL_Crlpath | Retrieved_Gtid_Set | Executed_Gtid_Set | Auto_Position | Replicate_Rewrite_DB | Channel_Name | Master_TLS_Version |
+----------------------------------+-------------+-------------+-------------+---------------+------------------+---------------------+-------------------------+---------------+-----------------------+------------------+-------------------+-----------------+---------------------+--------------------+------------------------+-------------------------+-----------------------------+------------+------------+--------------+---------------------+-----------------+-----------------+----------------+---------------+--------------------+--------------------+--------------------+-----------------+-------------------+----------------+-----------------------+-------------------------------+---------------+---------------+----------------+----------------+-----------------------------+------------------+--------------------------------------+----------------------------+-----------+---------------------+--------------------------------------------------------+--------------------+-------------+-------------------------+--------------------------+----------------+--------------------+--------------------+-------------------+---------------+----------------------+--------------+--------------------+
| Waiting for master to send event | mysql2      | replicator  |        3306 |            60 | mysql-bin.000003 |                 154 | mysql1-relay-bin.000002 |           320 | mysql-bin.000003      | Yes              | Yes               |                 |                     |                    |                        |                         |                             |          0 |            |            0 |                 154 |             528 | None            |                |             0 | No                 |                    |                    |                 |                   |                |                     0 | No                            |             0 |               |              0 |                |                             |              102 | 624e65eb-7e6d-11e6-8136-0242ac110003 | /var/lib/mysql/master.info |         0 |                NULL | Slave has read all relay log; waiting for more updates |              86400 |             |                         |                          |                |                    |                    |                   |             0 |                      |              |                    |
+----------------------------------+-------------+-------------+-------------+---------------+------------------+---------------------+-------------------------+---------------+-----------------------+------------------+-------------------+-----------------+---------------------+--------------------+------------------------+-------------------------+-----------------------------+------------+------------+--------------+---------------------+-----------------+-----------------+----------------+---------------+--------------------+--------------------+--------------------+-----------------+-------------------+----------------+-----------------------+-------------------------------+---------------+---------------+----------------+----------------+-----------------------------+------------------+--------------------------------------+----------------------------+-----------+---------------------+--------------------------------------------------------+--------------------+-------------+-------------------------+--------------------------+----------------+--------------------+--------------------+-------------------+---------------+----------------------+--------------+--------------------+
1 row in set (0.00 sec)

mysql> ^DBye
/opt2/mysql$
