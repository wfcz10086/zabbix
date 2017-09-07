#!/bin/bash
source ./colour
source ./install.ini
function oneproxy_install()
{
	echo -e "开始安装读写分离中间件"
	sleep 3
	cat << EOF > /usr/local/oneproxy/conf/proxy.conf
[oneproxy]
keepalive = 1
log-file  = /var/log/oneproxy.log
pid-file  = /var/log/oneproxy.pid
lck-file  = /var/log/oneproxy.lck

admin-address            = 0.0.0.0:4041
proxy-address            = 0.0.0.0:3307
proxy-master-addresses =$master:3306@server1
proxy-slave-addresses  =$slave:3306@server1

proxy-user-list          = zabbix/EA533C0350026E84DC33CF61D1BFE29A1E9F66CD@zabbix

proxy-group-security     = server1:0
proxy-group-policy       = server1:read-slave	
EOF
	echo -e "读写分离中间件配置...${green}ok${NC}"
	\cp -a ./../etc/rc.d/init.d/oneproxy /etc/rc.d/init.d/
	service oneproxy restart
	echo -e "读写分离中间正在启动...${green}ok${NC}"
	echo "管理命令为 mysql -uadmin -pOneProxy -h127.0.0.1 --port=4041"
	echo "访问端口为 mysql -uzabbix -pzabbix -h127.0.0.1 --port=3307 "
	echo -e "读写分离中间件安装完成...${green}ok${NC}"
	bash install.sh	
}
