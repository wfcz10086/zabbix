#!/bin/bash
source ./colour
source ./install.ini
function zabbix-slave_change_master()
{
	echo -e "正在绑定ip"
	ping -c2 $master  >/dev/null 2>&1
	if [ $? -eq 0 ]
	then
		echo -e "不需要绑定$master...${green}还存活${NC}" 
		exit        
	else	
		\cp -a ifcfg-en*:0  /etc/sysconfig/network-scripts/
		systemctl restart network.service
		cat << EOF >/etc/zabbix/zabbix_server.conf
LogFile=/var/log/zabbix/zabbix_server.log
LogFileSize=0
PidFile=/var/run/zabbix/zabbix_server.pid
#DBSocket=/app/mysql/mysql.sock
DBPort=3306
LogSlowQueries=3000
StartProxyPollers=10
DBHost=$slave
DBName=zabbix
DBUser=$mysql_count
DBPassword=$mysql_passwd
StartPollers=64
StartIPMIPollers=3
StartPollersUnreachable=64
StartDiscoverers=8
CacheSize=1024M
HistoryCacheSize=512M
TrendCacheSize=1024M
ValueCacheSize=256M

Timeout=30
EOF
	

cat << EOF >/etc/zabbix/web/zabbix.conf.php
<?php
// Zabbix GUI configuration file.
global \$DB;

\$DB['TYPE']     = 'MYSQL';
\$DB['SERVER']   = '$slave';
\$DB['PORT']     = '3306';
\$DB['DATABASE'] = 'zabbix';
\$DB['USER']     = '$mysql_count';
\$DB['PASSWORD'] = '$mysql_passwd';

// Schema name. Used for IBM DB2 and PostgreSQL.
\$DB['SCHEMA'] = '';

\$ZBX_SERVER      = 'localhost';
\$ZBX_SERVER_PORT = '10051';
\$ZBX_SERVER_NAME = '';

\$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;

EOF

	echo -e "重启各个服务"
	service mysqld restart
	echo -e "重启数据库完毕...${green}ok${NC}"
	service httpd restart
        echo -e "重启web服务完毕...${green}ok${NC}"
	service zabbix-server restart
        echo -e "重启zabbix-server服务完毕...${green}ok${NC}"

	service oneproxy restart
        echo -e "重启读写分离中间件完毕...${green}ok${NC}"
	bash install.sh
	fi


}
