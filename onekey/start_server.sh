#!/bin/bash
source ./colour
source ./install.ini
function start_server()
{
	echo -e "添加开机启动"
	systemctl enable mysqld
	systemctl enable httpd
	systemctl enable zabbix-server
	systemctl enable zabbix-agent
	chkconfig --add oneproxy
	echo -e "添加开机启动完毕...${green}ok${NC}"
	\cp -a  ./../usr/bin/dnt /usr/bin/dnt
	sed -i "s/dnt/$mysql_passwd/g" /usr/bin/dnt	
	sed -i "s/10.128.64.9/$slave/g" /usr/bin/dnt
	sed -i "s/root/$mysql_count/g" /usr/bin/dnt
	dnt
	bash install.sh
}
