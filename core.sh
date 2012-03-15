#/bin/bash
#需要安装yum -y install sharutils
dir='/usr/local/kor/'
mail_list='lijun877@gmail.com'
ip_addr=$(ifconfig eth0 |grep inet |awk -F: '{print $2}'|awk  '{print $1}')
for core_name in  `find  $dir  -name "core.[0-9]*[0-9]" -a -mmin -1 `
    do
        core_time=$(ls --full-time $core_name | awk '{print $6,$7}')
        corefile_name=$(basename $core_name)
        core_dir=$(dirname $core_name)
        server_name=$(find $core_dir  -maxdepth 1 -perm -700 -a ! -type d -exec file {} \;|grep  -i "lsb exe"|awk '{print $1}'|tr -d :)
        echo "$server_name   dump   $corefile_name  $ip_addr" | mail -s "$server_name   dumped the   $corefile_name  at  $core_time(server:$ip_addr)"  $mail_list 
    done
