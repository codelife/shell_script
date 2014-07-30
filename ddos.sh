#!/bin/bash
log_dir="/usr/local/nginx/logs/"
if [ -f ddos_tmp ];then
    rm ddos_tmp
fi

if [ -z $1 ];then
    echo "usage: $0 logfile"
    exit 1
fi

if [ !-f $1 ];then
    echo "file $log_dir/$1 is not exist"
    exit 1
fi

cat  $log_dir/$1 |awk -F' ' '{if($9==444)print $1 $7}' | sort  |uniq -c | awk -F' ' '{if($1>100){print $2}}' | awk -F':' '{print $1}' >> ./ddos_iplist
cat ./ddos_iplist |sort |uniq > ddos_tmp
mv ddos_tmp ddos_iplist

iptables -I INPUT -p tcp --dport 80 -j ACCEPT
iptables -D INPUT -p tcp --dport 80 -j web 
iptables -X web

iptables -N web
iptables -A web -j ACCEPT
iptables -I INPUT -p tcp --dport 80 -j web 
iptables -D INPUT -p tcp --dport 80 -j ACCEPT

for ip in `cat ddos_iplist`;do
    iptables -I web -s $ip -j DROP
done

exit 0 
