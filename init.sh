#/bin/bash
#在新安装的CentOS机器上执行此脚本,对eth1完全开放,对192.168.100.0/24开放.
ssh_port=12324                    #ssh的新端口
new_user="gamemanager"              #添加新用户
password="seegame"
grep -iq port=$ssh_port  /etc/ssh/sshd_config  
if [ $? -eq 0 ];then
    echo "Already init this machine"
    exit 1;
fi

sed -i '/^#Port/a\\Port='$ssh_port'' /etc/ssh/sshd_config
sed -i '/^#PermitRootLogin/a\\PermitRootLogin no\nMaxAuthTries 2\n' /etc/ssh/sshd_config
sed -i 's/\<22\>/'$ssh_port'/' /etc/sysconfig/iptables
sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
setenforce 0
echo "# Generated by iptables-save v1.4.7 on Wed Aug  3 12:43:01 2011
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [109:10676]
-A INPUT -i lo -j ACCEPT 
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT 
-A INPUT -i eth1 -j ACCEPT 
-A INPUT -s 180.168.101.72/29 -p tcp -m tcp --dport 12324 -j ACCEPT 
-A INPUT -p udp -m udp --dport 123 -j ACCEPT 
-A INPUT -p icmp -m icmp --icmp-type any -j ACCEPT 
-A INPUT -s 180.168.101.72/29 -p tcp -m tcp --dport 10050 -j ACCEPT 
-A INPUT -j REJECT --reject-with icmp-host-prohibited 
COMMIT
# Completed on Wed Aug  3 12:43:01 2011" > /etc/sysconfig/iptables
iptables-restore < /etc/sysconfig/iptables 
#########
#ulimit
#########
echo -e "   *   hard   nofile 102400\n   *   soft   nofile 102400\n" >> /etc/security/limits.conf
#######################
#user
#######################
useradd $new_user
usermod -G wheel $new_user
echo  "%wheel        ALL=(ALL)       ALL" >> /etc/sudoers
sed -i '/^PATH/a\\PATH=$PATH:/usr/kerberos/sbin:/usr/local/sbin:/usr/sbin:/sbin\n'  /home/$new_user/.bash_profile
killall ntpd
echo "nameserver 8.8.8.8" >> /etc/resolv.conf 
rm /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime
yum check-update
yum install ntp
ntpdate time.stdtime.gov.tw
if [ $? -eq 0 ];then
    hwclock -w
else
    echo -e "please check the time agine and then  run \"hwclock -w\" "
fi
/etc/init.d/ntpd start
chkconfig ntpd on
yum -y install gcc automake expect screen
echo -e "
export HISTTIMEFORMAT='%F %T '
export HISTSIZE=3000
export HISTCONTROL=ignoredups
export HISTIGNORE=\"pwd:ls:ls -ltr:ls -l:date:\"
alias  rm='rm -f'
" >> /etc/bashrc
iptables -I INPUT -p tcp --dport 12324 -j ACCEPT
expect -c "
        set timeout 5;
        spawn passwd $new_user
        expect \"UNIX password:\" { send \"$password\r\";};
        sleep 3;
        expect \"UNIX password:\" { send \"$password\r\";};
        expect eof;"
echo "首先修改$new_user的密码,然后再重启sshd,不然将无法远程登录"
echo "重启过sshd后,使用新的用户和端口登录,若在机房登录后,删除iptables中允许任意ip登录的规则"
