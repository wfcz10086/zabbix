#!/bin/bash

# 自行修改ZBX_URL变量，改为你的zabbix的web访问地址,其他变量不需要改变
ZBX_URL=`cat ./../../system/ops_config.php | grep zabbix_url| awk -F '=' '{print $2}'|tr -d '\";' `
 
USERNAME=`cat ./../../system/ops_config.php | grep zabbix_user| awk -F '=' '{print $2}'|tr -d '\";'`
PASSWORD=`cat ./../../system/ops_config.php | grep zabbix_pass| awk -F '=' '{print $2}'|tr -d '\";'`
ITEMID=""
STIME=""
PERIOD=3600
WIDTH=800
GRAPH_DIR=`cat ./../../system/ops_config.php | grep zabbix_chart| awk -F '=' '{print $2}'|tr -d '\";'`
COOKIE="/tmp/zabbix_cookie"
CURL="/usr/bin/curl"
INDEX_URL="$ZBX_URL/index.php"
CHART_URL="$ZBX_URL/chart.php"
 
function help()
{
    cat << HELP
Usage:
    $0  -I <itemid> [-s <stime>] [-p <period>] [-w <width>] [-h]
Options:
    -I ITEMID       itemid, integer, mandatory parameter
    -s STIME        graph start time, integer
                    Example: 20170520093000
    -p PERIOD       period in seconds, integer
                    Default: $PERIOD
    -w WIDTH        graph width, integer
                    Default: $WIDTH
    -h              show this help and exit
HELP
        exit 1
}
 
function check_integer()
{
    # 判断参数，如果不是整数返回1
    local ret=`echo "$*" | sed 's/[0-9]//g'`
    [ -n "$ret" ] && return 1
    return 0
}
 
if [ $# == 0 ]; then
    help
fi
 
while getopts U:P:I:s:p:w:h OPTION;do
    case $OPTION in
        U) USERNAME=$OPTARG
        ;;
        P) PASSWORD=$OPTARG
        ;;
        I) ITEMID=$OPTARG
        check_integer "$ITEMID" || { echo "ERROR: Field 'ITEMID' is not integer."; exit 1;}
        ;;
        s) STIME=$OPTARG
        check_integer "$STIME" || { echo "ERROR: Field 'STIME' is not integer."; exit 1;}
        ;;
        p) PERIOD=$OPTARG
        check_integer "$PERIOD" || { echo "ERROR: Field 'PERIOD' is not integer."; exit 1;}
        [ $PERIOD -lt 3600 -o $PERIOD -gt 63072000 ] && { echo "ERROR: Incorrect value $PERIOD for PERIOD field: must be between 3600 and 63072000."; exit 1;}
        ;;
        w) WIDTH=$OPTARG
        check_integer "$WIDTH" || { echo "ERROR: Field 'WIDTH' is not integer."; exit 1;}
        ;;
        h|\?) help
        ;;
    esac
done
 
# USERNAME、PASSWORD、ITEMID为必需参数
[ -z "$USERNAME" -o -z "$PASSWORD" -o -z "$ITEMID" ] && { echo "ERROR: Missing mandatory parameter."; help;}
# 如果没有传入STIME参数，STIME的值为当前时间减去PERIOD
[ "$STIME" == "" ] && STIME=`date -d "now -${PERIOD} second" +%Y%m%d%H%M%S`
 
echo USERNAME=$USERNAME PASSWORD=$PASSWORD ITEMID=$ITEMID STIME=$STIME PERIOD=$PERIOD WIDTH=$WIDTH
 
if [ ! -s "$COOKIE" ];then
    # 如果cookie文件不存在或者为空，则重新登录zabbix，并保存cookie文件
    ${CURL} -c ${COOKIE} -d "name=${USERNAME}&password=${PASSWORD}&autologin=1&enter=Sign+in" $INDEX_URL | egrep -o "(Login name or password is incorrect|Account is blocked.*seconds)"
    # 如果登录失败则退出脚本，并清空cookie文件
    [ ${PIPESTATUS[1]} -eq 0 ] && { :>"$COOKIE"; exit 1;}
fi
 
[ -d "$GRAPH_DIR" ] || mkdir -p "$GRAPH_DIR"
PNG_PATH="$GRAPH_DIR/$ITEMID.$PERIOD.${WIDTH}.png"
# 获取item的graph，保存为png图片（zabbix2.2版本）
#${CURL} -b ${COOKIE} -d "itemid=${ITEMID}&period=${PERIOD}&stime=${STIME}&width=${WIDTH}" $CHART_URL > "$PNG_PATH"
# zabbix3.2版本使用下面的URL
${CURL} -b ${COOKIE} -d "itemids%5B0%5D=${ITEMID}&period=${PERIOD}&stime=${STIME}&width=${WIDTH}" $CHART_URL > "$PNG_PATH"
[ -s "$PNG_PATH" ] && echo "Saved the graph as $PNG_PATH" || echo "Failed to get the graph."
echo "If the graph is not correct, please check whether the parameters are correct or clean $COOKIE file."
