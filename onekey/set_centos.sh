#!/bin/bash
source ./colour
function set_centos()
{
	echo "关闭防火墙..."
	iptables -F
	systemctl stop firewalld.service 
	systemctl disable firewalld.service
	echo -e "关闭防火墙...${green}ok${NC}"
	echo "关闭SElinux..."
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
	sed -i 's/SELINUX=permissive/SELINUX=disabled/' /etc/selinux/config
	setenforce 0
	echo -e "关闭SElinux...${green}ok${NC}"
	echo "正在清理RPM包"
	rpm -aq|egrep 'zabbix|httpd|php|mysql|mariadb'|xargs rpm -e --nodeps  >/dev/null 2>&1
 	echo -e "清理RPM包...${green}ok${NC}"
	echo "正在备份YUM源"
	\cp -a /etc/yum.repos.d /etc/yum.repos.d_bak
	echo "正在配置YUM源"
	\cp -a ./../etc/yum.repos.d/* /etc/yum.repos.d/
	echo -e "配置YUM源...${green}ok${NC}"
        echo "正在矫正时间"
	rm -rf /etc/localtime
	ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
	ntpdate time.nist.gov
	date
	echo -e "时间矫正...${green}ok${NC}"
	echo "系统初始化结束"
	
	bash install.sh
}
