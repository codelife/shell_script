#!/bin/bash
#use for implement the website automaticlly
#main function :tar the files in the remote server and modify the file in local
#函数的顺序问题,有的函数需要其他函数来先改变变量值 IP地址
SERVERNAME_ORIG="" #服务器原来域名,不做任何改变,以后添加新功能
SERVERNAME_NEW=""  #服务器新的域名
SERVERIP_WAN=""    #服务器原先的外网IP地址,由脚本自动提取虚拟主机中配置的ip为文件中的IP为源服务器IP外网地址
SERVERIP_LAN=""    #服务器原先的外网IP地址,由脚本自动提取memcached_cluster.xml文件中的IP为源服务器IP内网地址
IP_WAN=""          #服务器新的外网IP地址,由脚本自动提取eth0的IP地址为新服务器的外网IP
IP_LAN=""          #服务器新的内网IP地址,有脚本自动提取eth1的IP地址为新服务器的内网IP
WEBFILE="AUTOWEB"  #网站文件打包后的名称,
TARDIR="$HOME/upt"
APACHEDIR="/etc/apache2"
APACHEDIR_NEW="/etc/apache2"
USERNMAE="king" #新服务器的用户名
SQLUSER="sdfjskdfj" #服务器sql数据库用户名
SQLPASSWD='111111'  #新服务器的sql用户名
TOMCATNAME=""
TAR_FILE()
{
    test -d $HOME/upt/ || mkdir -v $HOME/upt/
    if [ -d $APACHEDIR ]; then
        tar --exclude=logs -chvf $TARDIR/$WEBFILE.tar $APACHEDIR/httpd.conf $APACHEDIR/sites-enabled/* /home/web/* > $HOME/upt/tar.log 2>&1  && echo "tar have been done successfully;" || echo "there is something wrong:please check the disk usage "
    else
       echo "请修改本脚本的APACHEDIR的值为apache的安装路径"
       exit 1 
    fi
    TOMCATNAME=`ls $HOME |grep 'apache-tomcat*'`
    cd $HOME && tar cvf $TARDIR/$TOMCATNAME.tar $TOMCATNAME
#    mysql -uroot -e "show databases" |grep -v 'mysql' |grep -v 'information_schema'
#    mysqldump -uroot --add-drop-table --add-drop-database -R -d --database `mysql -uroot -e "show databases" |grep -v 'mysql' |grep -v 'information_schema' |grep -v Database ` > $TARDIR/dump.sql
#    mysqldump -uroot --add-drop-table -R db_webplatform tb_roles tb_userinroles tb_users > $TARDIR/dumpdata.sql
     gzip -q  -v $TARDIR/$TOMCATNAME.tar 
     gzip -q  -v $TARDIR/$WEBFILE.tar 
}

localweb_process()
{
    if [ -z $TOMCATNAME ]; then
        echo "please give a value to variable TOMCATNAME;"
        exit 1;
    fi
    test -d /home/web/ || mkdir -v /home/web/
    #echo $TARDIR/$TOMCATNAME.tar.gz 
    #echo $TARDIR/$WEBFILE.tar.gz 
    if [ -e $TARDIR/$TOMCATNAME.tar.gz ] && [ -e $TARDIR/$WEBFILE.tar.gz ]; then
       cd $HOME && tar xzvf $TARDIR/$TOMCATNAME.tar.gz 
       cd / && tar -P -xzvf $TARDIR/$WEBFILE.tar.gz 
       cd $OLDPWD ||cd $HOME;
   else
       echo "确定压缩文件网站文件在$TARDIR下"
       exit 1;
   fi
   chown -R $USERNMAE. /home/web/
   return 0;
}

update_apacheconf()
{
    if [ -d $APACHEDIR_NEW ]; then
        :
    else
        echo "请修改本脚本的APACHEDIR_NEW的值为apache2的安装路径" 
        exit 1;
    fi
    grep -Ri 'listen 18080' $APACHEDIR_NEW|grep -v ":\s*#" || sed -i '$a\\listen 18080' $APACHEDIR_NEW/ports.conf 
    itemnum=`grep -iR namevirtualhost $APACHEDIR_NEW |grep -Ev ":\s*#" |wc -l`
    if [ $itemnum -gt 1 ]; then
        echo "Too many directive configure item about namevirtualhost:\n"
        echo `grep -iR namevirtualhost . | grep -Ev ":\s*#"`
        exit 1;
        test -z $itemnum && sed -i '1a\\NameVirtualHost *' $APACHEDIR_NEW/apache2.conf
    elif [ $itemnum -eq 1 ] && [ -z $SERVERIP_WAN ]; then
    SERVERIP_WAN=`grep -iR namevirtualhost $APACHEDIR_NEW |grep -Ev ":\s*#" |awk -F: '{print $2}' |awk '{print $2}'`
    echo "The orignal wan address is:$SERVERIP_WAN ,if it's not right please modify the script mannually"
    sleep 2; 
    else
        echo "There no namevirtualhost configure"
        sed -i /etc
        exit 1;
    fi
    grep -Rl "$SERVERIP_WAN" . |xargs -i sed -i 's/'$SERVERIP_WAN'/'$IP_WAN'/g' {}
    #if [ -d /usr/lib/jvm/java-6-sun ]; then
    sed -i '/workers.java_home=/c\workers.java_home=\/usr\/lib\/jvm\/java-6-sun'
    sed -i '/workers.tomcat_home=/c\workers.tomcat_home='$HOME'/'$TOMCATNAME''
   # else
   #    echo "make sure  you have installed the jdk correctly!"
   #    exit 1;
   #fi
    grep -Ri directoryindex $APACHEDIR_NEW |grep -v ':#' |grep '.jsp' || echo "DirectoryIndex default.jsp index.jsp index.htm index.html" >> $APACHEDIR_NEW/httpd.conf
    grep -Ri jkworkersfile $APACHEDIR_NEW || cat /usr/share/doc/libapache2-mod-jk/httpd_example_apache2.conf >> $APACHEDIR_NEW/apache2.conf || echo "make sure you have install the libapache2mod_jk"
    /etc/init.d/apache2 restart || echo -e "\033[32m WARNING :apache2 cant't be start,please check it later\033[0m" && sleep 2;
}

update_webconf()
{
    so_check
    test -z $SERVERIP_LAN && SERVERIP_LAN=$(grep 12000 `find /home/web/ -name memcached_cluster.xml |head -1` |awk -F: '{print $1}'|head -1 |awk -F'>' '{print $2}')
    grep -q CLASSPATH /etc/environment || sed -i '$a\\CLASSPATH=/usr/lib/jvm/java-6-sun/lib\nJAVA_HOME=/usr/lib/jvm/java-6-sun' /etc/environment
    find /home/web/ -maxdepth 4 -name handler.config |xargs -i sed  -i '/\s*<Providers>/,/\s*<\/Providers>/{s/\(username=\|user=\)".*"\(\s*password=\)/\1"'$SQLUSER'"\2/;s/password=".*"\(\s*database\)/password="'$SQLPASSWD'"\1/;}' handler.config
    find /home/web/ -maxdepth 4 -name handler.config |xargs -i sed  -i  '/\s*<Providers>/,/\s*<\/Providers>/{s/192\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/'$IP_LAN'/;/AuthenticateServerNetProvide/s/"[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"/"'$IP_WAN'"/;}' {}
    find /home/web/ -maxdepth 4 -name memcached_cluster |xargs -i sed  -i 's/'$SERVERIP_LAN'/'$IP_LAN'/' {}
    kill -9 ` ps x |grep java |grep -v grep |awk '{print $1}'` 
    chown -R $USERNMAE. $HOME/$TOMCATNAME
    $HOME/$TOMCATNAME/bin/startup.sh || echo -e "\033[32m WARNING:The tomcat can't be restart\033[0m;please check it later "
    cd /home/web/memcache && ./memcached -d -m 50 -l $IP_LAN -p 12000 
    sleep 2;
}

so_check()
{
    grep '/home/so' /etc/ld.so.conf || echo "/home/so" >> /etc/ld.so.conf
    grep '/home/sbin/lib/' /etc/ld.so.conf || echo "/home/sbin/lib/" >> /etc/ld.so.conf
    ldconfig 
}

mysql_conf()
{
    grep innodb_buffer_pool_size /etc/mysql/my.cnf || sed -i '/\[mysqld\]/a\\skip-name-resolve\ninnodb_buffer_pool_size = 208M\ninnodb_flush_log_at_trx_commit = 2 \ndefault-character-set=utf8 \nlower_case_table_names = 1\nskip-external-locking\n' /etc/mysql/my.cnf 
    sed -i '/\[client\]/a\\default-character-set=utf8' /etc/mysql/my.cnf
    mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO '$SQLUSER'@'%' IDENTIFIED BY '$SQLPASSWD' WITH GRANT OPTION;"
    mysql -uroot -e "use mysql;delete from user where user='root';"
    mysql -uroot -e "use mysql;delete from user where user='';"
    mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '' WITH GRANT OPTION;"
    mysql -uroot -e "flush privileges;"
    sed -i 's/127\.0\.0\.1/'$IP_LAN'/' /etc/mysql/my.cnf
    /etc/init.d/mysql restart && echo -e "\033[32m WARNING :The mysql cant't be start,please check it later\033[0m"
}

get_localip()
{
    if [ `grep 'eth0\|eth1' /etc/network/interfaces |wc -l ` -lt 4 ]; then
       echo "please check configure file of the network ,make sure you have two ip address" 
       exit 1;
    else
    test -z $IP_WAN && IP_WAN=`ifconfig eth0 |grep -w inet |awk -F: '{print $2}'|awk '{print $1}'`
    test -z $IP_LAN && IP_LAN=`ifconfig eth1 |grep -w inet |awk -F: '{print $2}'|awk '{rint $1}'`
    fi
    return 0;
}

update_game()
{
    sed -i '/addr\|url/{s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/'$IP_WAN'/g}' $HOME/www/version.xml
}
cp /etc/fstab /etc/fstab.bak 2> /dev/null || echo "you should run this script use sudo:sudo ./`basename $0`"
case $1 in 
-c)
    TAR_FILE && echo "tar and the compress process are going well"
    ;;
-x)
    echo " \033[31m Make sure you are on the right server!!! \033[0m" 
    cat /etc/network/interfaces 
    read -t 5  -p "确定是在新服务器上进行配置操作(Y/N):" confirm
    if [ -z $confirm ];then
        exit 1;
    elif [[ "$confirm" = "Y" ]] || [[ "$confirm" = "y" ]];then
        :
    else
        exit 1;
    fi
    reset;
    get_localip && echo "The IP address of local machine are--- WAN:$IP_WAN  LAN:$IP_LAN" ||echo "please check the network setting" 
    mysql_conf && echo "The configure about mysql is going well;The username : $SQLUSER ,password:$SQLPASSWD"
    read -t 5 -p "make sure the ip address and the sql configure are right,else you can chang it manully ;to be continue...(Y/N)" react
    if [ -z $react ];then
        exit 1;
    elif [[ "$react" = "Y" ]] || [[ "$react" = "y" ]];then
        :
    else
        exit 1;
    fi
    localweb_process && echo "the uncompress process are going well"
    update_apacheconf 
    update_webconf
    #update_game
    ;;
 *)
    echo  "usage: $0 [option] "
    echo  "             [-c] #used for the in server"
    echo  "             [-x] #used for the in testserver"
    ;;
esac

