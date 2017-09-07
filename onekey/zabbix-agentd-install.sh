#!/bin/bash
source ./colour
source ./install.ini
function zabbix-agent-install()
{
	echo -e "开始配置Zabbix-Agentd请等待..."
	ip=`ip addr|grep inet| grep  en|awk '{print $2}'|awk -F '/' '{print $1}'`
	cat << EOF > /etc/zabbix/zabbix_agentd.conf
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=0
Server=$master
ServerActive=$master
Hostname=$ip
StartAgents=5
DebugLevel=3
Timeout=10
RefreshActiveChecks=120
Include=/etc/zabbix/zabbix_agentd.d/*.conf

EOF



	echo -e "Zabbix-agentd配置...${green}ok${NC}"
	service zabbix-agent restart
	echo -e "Zabbix-agentd启动...${green}ok${NC}"
	echo "Zabbix-agentd安装完成"
	bash install.sh
}
