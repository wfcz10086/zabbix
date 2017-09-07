#!/bin/bash
source ./colour
function master_slave_config()
{
        if [ -f ./install.ini ];
        then
        echo -e "install.ini 配置文件存在！${green}ok${NC}"
        echo -e "${green}正在导入数据${NC}"
	source ./install.ini
	mysql -uroot  -p$mysql_root_passwd mysql -e "GRANT ALL PRIVILEGES ON *.* TO '$mysql_count'@'%'IDENTIFIED BY '$mysql_passwd' WITH GRANT OPTION; "
        if [ ${?} != 0 ]
        then
                echo -e "你在本机mysql授权 配置错误${red}error${NC}"
		exit 
        else
                echo -e "你在本机mysql 授权成功！${green}ok${NC}"
        fi
	sshpass -p$slave_ssh_passwd  ssh -o TCPKeepAlive=yes  -o StrictHostKeyChecking=no root@$slave " mysql -uroot  -p$mysql_root_passwd mysql -e \"GRANT ALL PRIVILEGES ON *.* TO '$mysql_count'@'%'IDENTIFIED BY '$mysql_passwd' WITH GRANT OPTION; \" 2>&1"
	if [ ${?} != 0 ]
	then
		echo -e "你在$slave 配置错误${red}error${NC}"
		exit 
	else
		echo -e "$slave 授权成功！${green}ok${NC}  "
	fi	
	mysql_binlog=`mysql -uroot  -p$mysql_root_passwd mysql -e "show master status;"|grep -v File|awk '{print $1}'`
	mysql_binpost=`mysql -uroot  -p$mysql_root_passwd mysql -e "show master status;"|grep -v File|awk '{print $2}'`
	sshpass -p$slave_ssh_passwd  ssh -o TCPKeepAlive=yes  -o StrictHostKeyChecking=no root@$slave " mysql -uroot  -p$mysql_root_passwd mysql -e \"change master to master_host='$master',master_user='$mysql_count',master_password='$mysql_passwd',master_log_file='$mysql_binlog',master_log_pos=$mysql_binpost;\""
	if [ ${?} != 0 ]
        then
                echo -e "配置从服务器Slave ${red}error${NC}"
                echo "请您在$slave mysql上运行stop slave;"
		exit
        else
                echo -e "配置从服务器Slave ${green}ok${NC}  "
		
        fi
	sshpass -p$slave_ssh_passwd  ssh -o TCPKeepAlive=yes  -o StrictHostKeyChecking=no root@$slave " mysql -uroot  -p$mysql_root_passwd mysql -e \"start slave;\""
	slave_io=`mysql -u$mysql_count -p$mysql_passwd -h$slave  -e  "show slave status\G;" 2>&1| egrep 'Slave_IO_Running'|awk '{print $2}'`

	Slave_SQL_Running=`mysql -u$mysql_count -p$mysql_passwd -h$slave  -e  "show slave status\G;" 2>&1| egrep 'Slave_SQL_Running:'|awk '{print $2}'`
	if [ "$slave_io" != "Yes" ]
	then
		printf "$slave Slave_IO ${red} $slave_io ${NC}\r\n"
	else
	 	printf "$slave Slave_IO ${green} $slave_io ${NC}\r\n"
	fi


	if [ "$Slave_SQL_Running" != "Yes" ]
	then
        	printf "$slave Slave_SQL ${red} $Slave_SQL_Running ${NC}\r\n"
		
	else
         	printf "$slave Slave_SQL ${green} $Slave_SQL_Running ${NC}\r\n"
	fi
	 mysql -uroot -p$mysql_root_passwd -e "drop database zabbix;"
	 mysql -uroot -p$mysql_root_passwd -e "create database zabbix character set utf8 collate utf8_bin;"
		
	zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uroot -p$mysql_root_passwd zabbix
		echo "Mysql 主从复制自动配置成功"
		bash install.sh	
        else
      	echo -e "install.ini 配置文件不存在！${red}error${NC}"
		bash install.sh
        fi
	
	
}
