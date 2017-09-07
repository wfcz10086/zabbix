#!/bin/bash
source ./colour
source ./install.ini
function zabbix-server-install()
{
	echo -e "开始安装zabbix-server..."
	\cp -a ./../etc/zabbix /etc/
	\cp -a ./../etc/httpd /etc/
	cat << EOF >/etc/zabbix/zabbix_server.conf
LogFile=/var/log/zabbix/zabbix_server.log
LogFileSize=0
PidFile=/var/run/zabbix/zabbix_server.pid
#DBSocket=/app/mysql/mysql.sock
DBPort=3307
LogSlowQueries=3000
StartProxyPollers=10
DBHost=$master
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
	
	echo -e "Zabbix配置文件配置成功...${green}ok${NC}"
	service zabbix-server restart	
	echo -e "zabbix安装...${green}ok${NC}"
	

cat << EOF >/etc/zabbix/web/zabbix.conf.php
<?php
// Zabbix GUI configuration file.
global \$DB;

\$DB['TYPE']     = 'MYSQL';
\$DB['SERVER']   = '$master';
\$DB['PORT']     = '3307';
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

	echo -e "zabbix WEB配置...${green}ok${NC}"
	echo -e "请您访问http://$master/zabbix"
	echo -e "账号/密码:Admin/zabbix"

	bash install.sh
}
