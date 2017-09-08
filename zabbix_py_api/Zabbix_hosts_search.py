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

                                                                     



    def all_template_get(self):
    #获取所有模板
        data = json.dumps({
    "jsonrpc": "2.0",
    "method": "host.get",
    "params": {
        "output": "extend",
        "filter": {
            "host": [
                sys.argv[1]
            ]
        }
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
            print "Error as", e
        else:
            response =result.read()
            result.close()
	    if "hostid" in response:
            	rt=response.split(":")[3].split('"')[1]
		return rt
	    else:
		return "error"

                                                                          
if __name__ == "__main__":
    z = ZabbixTools(address=zabbix_url, token=zabbix_token)
    print sys.argv[1],z.all_template_get()
