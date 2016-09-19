use mysql;
create user 'replicator'@'%' identified by 'repl1234or';
grant replication slave on *.* to 'replicator'@'%';
FLUSH PRIVILEGES;
SHOW MASTER STATUS;
SHOW VARIABLES LIKE 'server_id';
