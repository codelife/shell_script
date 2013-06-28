#/bin/bash
#在新安装的CentOS机器上执行此脚本,对eth1完全开放,对192.168.100.0/24开放.
ssh_port=9527                  #ssh的新端口
new_user="yl9527"              #添加新用户
password="yourpasswd"          #新用户密码
company_ip="123456"
grep -iq  "$new_user:x" /etc/passwd
if [ $? -eq 0 ];then
    echo "Already init this machine"
    exit 1;
fi

#{ iptables setting

    sed -i '/^#Port/a\\Port='$ssh_port'' /etc/ssh/sshd_config
    sed -i '/^#PermitRootLogin/a\\PermitRootLogin no\nMaxAuthTries 2\n' /etc/ssh/sshd_config
    sed -i 's/\<22\>/'$ssh_port'/' /etc/sysconfig/iptables
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
    setenforce 0
    echo "
        *filter
        :INPUT ACCEPT [0:0]
        :FORWARD ACCEPT [0:0]
        :OUTPUT ACCEPT [109:10676]
        -A INPUT -i lo -j ACCEPT 
        -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT 
        -A INPUT -i eth1 -j ACCEPT 
        -A INPUT -i em1 -j ACCEPT 
        -A INPUT -p tcp --dport $ssh_port -j ACCEPT
        -A INPUT -p udp -m udp --dport 123 -j ACCEPT 
        -A INPUT -p icmp -m icmp --icmp-type any -j ACCEPT 
        -A INPUT -p tcp -m tcp --dport 10050 -j ACCEPT 
        -A INPUT -j REJECT --reject-with icmp-host-prohibited 
        COMMIT
    " > /etc/sysconfig/iptables
    iptables-restore < /etc/sysconfig/iptables 

#}

#{ install libs and software

  rpm -Uvh http://mirrors.ustc.edu.cn/fedora/epel/6/i386/epel-release-6-8.noarch.rpm
  rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
  rpm -Uvh http://apt.sw.be/redhat/el6/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm 
  yum check-update
  yum -y install gcc automake expect screen gcc-g++ ntpd wget unzip man vim

#{

#{ optimiz core parameters

    echo -e "   *   hard   nofile 60000\n   *   soft   nofile 65535\n" >> /etc/security/limits.conf
    echo -e "
    export HISTTIMEFORMAT='%F %T '
    export HISTSIZE=3000
    export HISTCONTROL=ignoredups
    export HISTIGNORE=\"pwd:ls:ls -l:date:\"
    alias  rm='rm -f'
    " >> /etc/bashrc
    source /etc/bashrc
    echo "
    #network optimiz
    net.ipv4.tcp_syncookies = 1
    net.ipv4.tcp_tw_reuse = 1
    net.ipv4.tcp_syn_retries = 2
    net.ipv4.tcp_synack_retries = 2
    net.ipv4.tcp_tw_recycle = 1
    net.ipv4.tcp_fin_timeout = 30
    net.ipv4.tcp_keepalive_time = 300
    net.ipv4.ip_local_port_range = 10000 65000
    net.ipv4.tcp_max_syn_backlog = 8192
    net.ipv4.tcp_max_tw_buckets = 6000
    net.core.netdev_max_backlog = 32768
    net.core.somaxconn = 32768
    net.core.wmem_default = 8388608
    net.core.rmem_default = 8388608
    net.core.rmem_max = 873200
    net.ipv4.tcp_wmem = 8192 436600 873200
    # TCP写buffer
    net.ipv4.tcp_rmem  = 32768 436600 873200
    # TCP读buffer
    net.ipv4.tcp_mem = 94500000 91500000 92700000
    " >> /etc/sysctl.conf
    sysctl -p
    
#}

#{ add new user and set password

    useradd $new_user
    usermod -a -G wheel $new_user
    echo  "%wheel        ALL=(ALL)       ALL" >> /etc/sudoers
    sed -i '/^PATH/a\\PATH=$PATH:/usr/kerberos/sbin:/usr/local/sbin:/usr/sbin:/sbin\n'  /home/$new_user/.bash_profile
    expect -c "
        set timeout 5;
        spawn passwd $new_user
        expect \"UNIX password:\" { send \"$password\r\";};
        sleep 3;
        expect \"UNIX password:\" { send \"$password\r\";};
        expect eof;"

#}


#{ time setting

    echo "nameserver 8.8.8.8" >> /etc/resolv.conf 
    rm /etc/localtime
    ln -s /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime
    ntpdate time.stdtime.gov.tw
    if [ $? -eq 0 ];then
        hwclock -w
    else
        echo -e "please check the time agine and then  run \"hwclock -w\" "
    fi
    killall ntpd
    /etc/init.d/ntpd start
    chkconfig ntpd on

#}

echo "首先修改$new_user的密码,然后再重启sshd,不然将无法远程登录"
echo "重启过sshd后,使用新的用户和端口登录,若在机房登录后,删除iptables中允许任意ip登录的规则"
