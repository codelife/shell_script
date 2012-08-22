#!/bin/bash - 
#===============================================================================
#
#          FILE:  update.sh
# 
#         USAGE:  ./update.sh 
# 
#   DESCRIPTION:  update file  to www.nuannuan.com
# 更新updatelist文件中的所有文件(必须为/var/www/html/Nuan目录下文件) 格式为文件的绝对路径
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: Collin Lee (), lijun877@gmail.com
#       COMPANY: SeeGame.COM
#       CREATED: 2012年08月21日 04时39分47秒 EDT
#      REVISION:  0.1
#===============================================================================

set -o nounset                              # Treat unset variables as an error
exec >> log.update
echo `date`
webroot="/var/www/html/Nuan"
filelist="/var/www/html/Nuan/updatelist"
passwd="sdfjskdfj"
host="192.168.1.23s"
sed -i "s#$webroot#.#" $filelist
cd $webroot
/bin/rm new.tgz
tar czvf new.tgz -T $filelist
expect -c "
spawn scp -P12324  new.tgz  user111@$host:~/
expect \"password:\" { send \"$passwd\r\";}
expect eof
" 
while( [ `ps aux |grep "scp.*$host" |grep -v grep  |wc -l` -eq 1 ] );do
    sleep 1
done
#解压文件到目标目录
expect -c "
spawn ssh -p12324  user111@$host  \" tar xzvf /home/user111/new.tgz -C  /home/user111/bak/\"
expect \"password:\" { send \"$passwd\r\";}
expect eof
" 

