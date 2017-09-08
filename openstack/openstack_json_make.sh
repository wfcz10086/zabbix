#!/bin/bash
#王文强
#天玑科技-武汉分公司
#手机15857346148
#邮箱 wenqiang_wang@dnt.com.cn
#本脚本为zabbix-openstack模块数据采集套件之一，仅供参考。
#获取token
name="test"
password="test"
id="test"
token=`curl -i -k -d '{"auth":{"identity":{"methods":["password"],"password":{"user":{"name":"$name","password":"$password","domain":{"id":"$id"}}}},"scope":{"project":{"name":"Jxqx_VDC1","domain":{"id":"$id"}}}}}' -H "Content-type: application/json" https://identity.az1.dc1.domainname.com:443/identity/v3/auth/tokens|awk -F 'X-Subject-Token:' '{print $2}'|tr -d '\r\n' |tr -d ' '`


#curl命令组装
cmd_run="curl -# -ki -X GET -H 'X-Auth-Token: $token' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'User-Agent: python-ceilometerclient' "


#获取虚机列表
echo "$cmd_run" https://compute.az1.dc1.domainname.com:443/v2/a93de5cf150142c2a9e91291f5fa8a6d/servers|sh|awk -F '"id":'  '{ for(i=1;i<NF;i++) {print $i}}'|awk '{print $1}'|sort -rn|uniq -i|egrep -v 'null|{|liks'|tr -d '",'>/tmp/.json_openstack

#openstack获取数据模块
function openstack_run {
	value=`curl -ki -X GET -H "X-Auth-Token: $token" -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'User-Agent: python-ceilometerclient'  "https://metering.az1.dc1.domainname.com:443/v2/meters/$1?limit=1&q.field=resource&q.op=eq&q.type=&q.value=$2"|sed   's/{/{\r\n/g'|sed 's/,/,\r\n/g'|grep counter_volume|awk '{print \$2}'|tr -d ','`
	echo $value
}

#获取列表并循环
cat /tmp/.json_openstack|while read list
do
    #获取source_id
	openstack_compute_id=`echo "$list"|awk '{print $1}'`
	openstack_compute_id_json=`echo "$cmd_run" "\"https://compute.az1.dc1.domainname.com:443/v2/a93de5cf150142c2a9e91291f5fa8a6d/servers/$openstack_compute_id\"" |sh`
    #获取ip
	ip=`echo $openstack_compute_id_json |sed   's/{/{\r\n/g'|sed 's/,/,\r\n/g'|grep "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"|awk '{print $2}'|tr -d '",'`
#	openstack_compute_id_host=`echo $openstack_compute_id_json |sed   's/{/{\r\n/g'|sed 's/,/,\r\n/g'|grep  "\"hostname\": "` 
	cpu_util=`openstack_run cpu_util $openstack_compute_id`
    #获取cpu
	mem_util=`openstack_run mem_util $openstack_compute_id`
    #获取内存
	echo -e " $cpu_util \t cpu_util  \t $ip"
	echo -e " $mem_util \t mem_util  \t $ip"
    #打印输出到缓存文件

	
done
