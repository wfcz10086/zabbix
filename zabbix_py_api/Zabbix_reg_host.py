#!/usr/bin/python
#coding:utf-8
import json
import urllib2
from urllib2 import URLError
import sys,commands
reload(sys)
sys.setdefaultencoding('utf-8')
#定义一些变量

zabbix_url=commands.getoutput("cat ./../../system/ops_config.php | grep zabbix_url| awk -F '=' '{print $2}'|tr -d '\";'")
zabbix_token=commands.getoutput("cat ./../../system/ops_config.php | grep zabbix_token| awk -F '=' '{print $2}'|tr -d '\";'")
class ZabbixTools:
    def __init__(self,address,token):
                                                                      
        self.address = address
        self.token = token
        #请求之前进行json 数据组装                                                              
        self.url = '%s/api_jsonrpc.php' % self.address
        self.header = {"Content-Type":"application/json"}
                                                                      
                                                                      
                                                                          
    def host_create(self,hostname,ip,groupid,temlpateid):
    #这个def 是创建新监控主机函数
        data = json.dumps({
    "jsonrpc": "2.0",
    "method": "host.create",
    "params": {
        "host": hostname, 
        "interfaces": [
            {
                "type": 1,
                "main": 1,
                "useip": 1,
                "ip": ip,
                "dns": "",
                "port": "10050"
            }
        ],
        "groups": [
            {
                "groupid": groupid
            }
        ],
        "templates": [
            {
                "templateid": temlpateid
            },
	    {
		"templateid": "10667"
	    }
	],

        "inventory_mode": 0,
    },
    "auth": self.token,
    "id": 1
})
                                                                      
        request = urllib2.Request(self.url, data)
        for key in self.header:
            request.add_header(key, self.header[key])
        try:
            result = urllib2.urlopen(request)
        except URLError as e:
	    print "Error as ", e
        else:
            response = result.read()
            result.close()
            return response


                                                                          
if __name__ == "__main__":
    z = ZabbixTools(address=zabbix_url, token=zabbix_token)
    print z.host_create(sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4])
