#/bin/bash
date=`date +%V-%d-%H-%M`
week=`date -d '2 week ago' +%V`
bak_dir=/home/gamemanager/redis_bak/
sour_dir=/root/bak/
rem_ip=192.168.100.14
if [ -d /root/bak ];then
:
else
mkdir /root/bak
fi
cp -f  /root/DB_data/dump.rdb  /root/bak/  || mail_collin
tar czvf  /root/bak/dump.rdb-$date.tar.gz /root/bak/dump.rdb  || mail_collin
rm -f /root/bak/dump.rdb
scp -P12324  $sour_dir/dump.rdb-$date.tar.gz  gamemanager@$rem_ip:$bak_dir/  
if [ $? -eq 0 ];then
rm -f /root/bak/dump.rdb-$date.tar.gz 
else 
ssh -p12324 gamemanager@192.168.100.14 df  -h  > /root/bak/df
mail -s "something wrong about redis dump on 192.168.100.14 "  -c  terry@seegame.com  collin@seegame.com < /root/bak/df
fi
ssh -p12324 gamemanager@$rem_ip  rm $bak_dir/dump.rdb-$week*
mail_collin()
{
df -h | mail -s "something wrong about redis dump on 192.168.100.13 " -c terry@seegame.com  collin@seegame.com  
exit 1
}

