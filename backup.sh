#/bin/bash
bak_sour='/usr/local/kor'
bak_date=`date +%m%d`
bak_name=$(basename $bak_sour)
bak_dest='/home/user/bak'
if [ -d $bak_dest ];then
:
else
mkdir $bak_dest
fi
tar --exclude="*.tar.gz" --exclude="*.log.bak*" --exclude="*.log" -czvf  $bak_dest/$bak_name$bak_date.tar.gz  $bak_sour
find $bak_dest -name "$bak_name*.tar.gz" -a  -mtime +7  -exec rm {} \;
