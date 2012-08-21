#!/bin/bash
exec 2>/dev/null
out()
{
n=1
for i in `ps x|grep sbin|grep -v grep |grep -v lobbserver|grep -v platform|awk '{print $5}'`
do

    dirname=`dirname $i`
    grep "GameName=" $dirname/coreconfig.xml|awk -F '"' '{printf("%-2d %-10s%-17s%-10s%-15s%-24s",'$n',$2,$4,$6,$8,$10)}'
    echo "$dirname/coreconfig.xml"
    n=$(( $n + 1 ))
done
}
out
num=`out|wc -l`
echo -n "Please input nemble:" 
read  line
if [[ $line -le $num && $line -ne 0 ]]
then
LANG=C
    nano `out|grep  -w "$line"|grep "^$line"|awk '{print $NF}'`
fi