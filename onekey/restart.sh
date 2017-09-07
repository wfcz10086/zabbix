#!/bin/bash
source ./colour
source ./install.ini
function restart_server()
{
	echo -e "重启各个服务"
	service mysqld restart
	echo -e "重启数据库完毕...${green}ok${NC}"
	service httpd restart
        echo -e "重启web服务完毕...${green}ok${NC}"
	service zabbix-server restart
        echo -e "重启zabbix-server服务完毕...${green}ok${NC}"

	service oneproxy restart
        echo -e "重启读写分离中间件完毕...${green}ok${NC}"









	dnt
	bash install.sh
	
}
