#!/bin/bash  
#menu.sh  
  
source ~/.bashrc  
source ./master_salve.sh 
source ./mysql_config.sh 
source ./oneproxy_config.sh 
source ./restart.sh .
source ./set_centos.sh 
source ./start_server.sh 
source ./yum.sh 
source ./zabbix-agentd-install.sh  
source ./zabbix-server-install.sh
source ./zabbix-slave_change_master.sh
echo "---------------天玑Zabbix读写分离集成配置环境-----------------"  
echo "----------------请您注意修改install.ini的配置文件--------------"
echo "please enter your choise:"  
echo "(0) 初始化环境"  
echo "(1) 安装RPM包"  
echo "(2) 重置Mysql密码"  
echo "(3) 一键主从"  
echo "(4) 一键读写分离" 
echo "(5) 一键安装Zabbix服务"
echo "(6) 一键安装Agentd"  
echo "(7) 一键添加开机自启"
echo "(8) 一键重启服务" 
echo "(11) 一键冷热备切换(在slave上运行)"
echo "(12) 一键优化" 
 
echo "(9) Exit Menu"  
echo "----------------------------------------------------------------"  
read input  
  
case $input in  
    0)  
    set_centos;;  
    1)  
    yum_rpm;;  
    2)  
    mysql_config;;  
    3)  
    master_slave_config 2>&1 |grep -v Warning;;  
    4)  
    oneproxy_install;;  
    5)  

    zabbix-server-install;;
    6)  
    
    zabbix-agent-install;;
    7)
    
    start_server;;
    8)
    
    restart_server;;

   11)

    zabbix-slave_change_master;;
    9)  
    exit;;  
esac  
