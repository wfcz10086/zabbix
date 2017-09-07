#!/bin/bash
source ./colour
function yum_rpm()
{
	echo -e "开始安装依赖包，时间较长，请等待..."
	
	sed -i 's/gpgcheck=1/gpgcheck=0/g' /etc/yum.repos.d/*
	yum localinstall -y ./../rpm/*.rpm  
#>/dev/null 2>&1
	echo -e "http安装...${green}ok${NC}"
	echo -e "mysql安装...${green}ok${NC}"
	echo -e "zabbix安装...${green}ok${NC}"
	echo -e "php安装...${green}ok${NC}"	
	echo -e "依赖包安装安装...${green}ok${NC}"
	\cp -a ./../usr/local/oneproxy /usr/local/
	echo -e "读写分离中间安装...${green}ok${NC}"
	bash install.sh
}

