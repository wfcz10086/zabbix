#!/bin/bash
source ./colour
function mysql_config()
{
        if [ -f ./install.ini ];
        then
        echo -e "install.ini 配置文件存在！${green}ok${NC}"
        echo -e "${green}正在导入数据${NC}"
	source ./install.ini

        service mysql restart
	service mysqld stop
	mv /var/lib/mysql /app  >/dev/null 2>&1
	\cp ./../etc/my.cnf /etc/
	service mysql restart
	service mysqld stop
	echo -e "${green}迁移数据到/app目录ok${NC}"
	mysqld_safe --user=mysql --skip-grant-tables --skip-networking &
	sleep 15
	mysql -u root mysql -e "update user set password=password('$mysql_root_passwd') where user='root';"
	ps -ef | grep "skip-grant-table"|awk '{print $2}'|xargs kill -9
	service mysqld restart
	echo -e "修改mysql 密码为$mysql_root_passwd ${green}ok${NC}"
	echo -e "Zabbix-Server mysql 配置完毕$mysql_root_passwd ${green}ok${NC}"
        else
      	echo -e "install.ini 配置文件不存在！${red}error${NC}"

        fi

#	bash install.sh
}
