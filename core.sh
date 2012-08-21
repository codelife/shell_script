#/bin/bash
#dir='/home/gamemanager/'
dir='/usr/local/kor/server/'
mail_list='collin@seegame.com '
for core_name in  `find  $dir  -name "core.[0-9]*[0-9]" -a -mmin -10 `
    do
        core_time=$(ls --full-time $core_name | awk '{print $6,$7}')
        corefile_name=$(basename $core_name)
        core_dir=$(dirname $core_name)
        server_name=$(find $dir_name  -maxdepth 1 -perm -700 -a ! -type d -exec file {} \;|grep  -i "lsb exe"|awk '{print $1}'|tr -d :)
        uuencode $core_name $corefile_name  | mail -s "$server_name dumped the $corefile_name at  $core_time"  $mail_list 
    done
    find  $dir  -name "core.[0-9]*[0-9]" -a -mtime +10 -exec rm -f {} \;
