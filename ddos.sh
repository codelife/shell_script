#!/bin/bash
pid_file="/usr/local/nginx/logs/nginx.pid"
log_dir="/usr/local/nginx/logs/"
ddos_iplist='/root/bin/ddos_iplist'
block_file='/root/bin/block_count'
tmp=`mktemp`
#分析文件中的444错误码并统计攻击ip
analy_file()
{
    if [ -z $1 ];then
        echo "usage: $0 logfile"
        exit 1
    fi

    if [ ! -f $1 ];then
        echo "file $1 is not exist"
        exit 1
    fi

    cat  $1 |awk -F' ' '{if($9==444)print $1 $7}' | sort  |uniq -c | awk -F' ' '{if($1>100){print $2}}' | awk -F':' '{print $1}' >> $ddos_iplist
    cat $ddos_iplist |sort |uniq > $tmp
    grep -v  "444 0" $1 >> $1.bak
    mv $tmp $ddos_iplist

}
#统计抵御的攻击数
block_count(){
count=`iptables -L -n -v | grep DROP |awk -F' ' '{if($1!=0){print $0}}' |sort -nr -k 1 |awk -F' ' '{a+=$1};END{print a}'`
time=`date "+%D %T"`
echo "$time   $count" >>  $block_file
}

#iptables封禁攻击源ip
block_ip()
{
    iptables -I INPUT -p tcp --dport 80 -j ACCEPT
    iptables -D INPUT -p tcp --dport 80 -j web 
    iptables -F web

    iptables -A web -j ACCEPT
    iptables -I INPUT -p tcp --dport 80 -j web 
    iptables -D INPUT -p tcp --dport 80 -j ACCEPT

    for ip in `cat $ddos_iplist`;do
        iptables -I web -s $ip -j DROP
    done
}

for file in `find $log_dir -name "*.access.log" `;do
    analy_file $file
done

kill -HUP `cat $pid_file`

block_count

block_ip

exit 0 
