#/bin/bash
#srcdir=/home/web/
src_dir=/usr/local/kor/client/
dst_ip="192.168.88.132"
dst_dir="/home/web/www.kuku01.com/"
username="user"
/usr/local/bin/inotifywait -mrq --timefmt '%d/%m/%y %H:%M' --format '%T %w%f%e' -e modify,delete,create,attrib  $src_dir \
| while read files
    do
        for ip_addr in $dst_ip
        do
            /usr/bin/rsync -vzrtopg -e 'ssh -p 12324' --delete --progress $src_dir $username@$ip_addr:$dst_dir
            echo "${files} was rsynced" >>/tmp/rsync.log 2>&1
        done
    done                 
