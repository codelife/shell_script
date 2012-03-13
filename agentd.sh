#/bin/bash
#zabbix server's ip address
zabbix_server="192.168.1.11"
if [ $UID -ne 0 ];then
echo "you are not root $su -"
exit 1 
fi
if [ -d ~/upt ];then
cd ~/upt
else
mkdir ~/upt
cd ~/upt
fi
yum -y install gcc automake make
wget http://nchc.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/1.8.5/zabbix-1.8.5.tar.gz
tar xzvf zabbix-1.8.5.tar.gz && cd zabbix-1.8.5
./configure --enable-agent
make install
useradd zabbix 
mkdir /etc/zabbix/
cp misc/conf/zabbix_agentd.conf  /etc/zabbix/
chown -R zabbix. /etc/zabbix/ 
sed -i 's/Server=127.0.0.1/Server='$zabbix_server'/' /etc/zabbix/zabbix_agentd.conf
/usr/local/sbin/zabbix_agentd
echo " all done the agentd has already started"
echo "/usr/local/sbin/zabbix_agentd" >> /etc/rc.local
