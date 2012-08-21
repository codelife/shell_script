#!/bin/bash
mip="192.168.0.200"
muser="sdjfksj"
mpasswd="aslkjdflasjfl"
TIME=`date +%H%M`
read -p "This script should be exec at the slave machine,are you sure continue(yes/no): " confirm;
if [ ${confirm} = "yes" ]
then 
    ;
else
    exit 0;
fi
spacket=$(mysql -uroot -e "show variables like 'max_allowed_packet%'\G;"  |grep -i 'value' |awk '{print $2}')
sbuffer=$(mysql -uroot -e "show variables like 'net_buffer_length'\G;"  |grep -i 'value' |awk '{print $2}'

if [ -d $HOME/upt ]
then
    ;
else
    mkdir $HOME/upt;
fi

mysqldump -h 192.168.0.200 -u wolfplus -p${mpasswd} --master-data=1 --extended-insert  --max_allowed_packet=${spacket} --net_buffer_length=${sbuffer}  --routines  --add-drop-database --single-transaction --default-character-set=utf8 --flush-logs --quick --all-databases >  $HOME/upt/dump${TIME}.sql
if [ $? -ne 0 ]
then 
    rm $HOME/upt/dump${TIME}.sql
    echo the dump is failure!!!!!;
fi
mysql -uroot  -e "reset slave;"
mysql -uroot --default-character-set=utf8 < $HOME/upt/dump${TIME}.sql 2 >> $HOME/upt/retrive.log
if [ $? -ne 0 ]
then
   echo  the retrive was failure , you should check the log at $HOME/upt/retrive.log
else
   #mysql -uroot -e "CHANG MASTER TO MASTER_HOST = '"${mip}"',MASTER_USER = '"${muser}"',MASTER_PASSWORD = '"${mpasswd}"',MASTER_LOG_FILE='master2-bin.001',MASTER_LOG_POS=4;"

   mysql -uroot -e "CHANG MASTER TO MASTER_HOST = '"${mip}"',MASTER_USER = '"${muser}"',MASTER_PASSWORD = '"${mpasswd}"';"
  echo `mysql -uroot -e "show slave status\G;"` 
