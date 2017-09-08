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
                                                                      
                                                                      
                                                                          

    def item_get(self,hostid):
    #这个函数是获取一个组下面所有主机的信息，包括主机id和主机名
        data = json.dumps({
    "jsonrpc": "2.0",
    "method": "item.get",
    "params": {
       "output":["itemid","key_"],
        "hostids": hostid,
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
            response =result.read()
            result.close()
            return response

if __name__ == "__main__":
    z = ZabbixTools(address=zabbix_url, token=zabbix_token)
    print z.item_get(sys.argv[1])
