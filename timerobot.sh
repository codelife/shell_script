#!/bin/bash
#scpritname:timerobot.sh
#脚本基本原理,启动所指定目录的的机器人--->1.加robotserver权限,2,杀死同名并且所连接的游戏服务相同的正在执行的robot,并且去执行权限,3.添加权限给新机器人,启动机器人
#robotdir='/home/king/robot/hcmj/'  #指定要定时启动的机器人所在目录,是服务端所在目录
if [[ $# -ne 1 || ! -d $1 ]]; then
    echo usage:$0 with the directory of the robot!
    exit 1
fi
robotdir=$1  #指定要定时启动的机器人所在目录,是服务端所在目录
robot_fullname=$(find $robotdir -maxdepth 1 ! -type d |grep -v '\.\|-\|bak\|core\|-')
robot_server=$(basename $robot_fullname)
robot_port=$(grep -qi 'listenport=' $robotdir/robotconfig.xml | awk '{i=1;while(i<=NF){if($i ~ /[Ll]isten[Pp]ort=\"[0-9]+\"/){split($i,p,"\"");print p[2];break}i++;}}')
for i in `ps x |grep $robot_server|grep -v grep |awk '{print $5}'`
do
    twin_dir=$(dirname $i)
    grep -iq "listenport=\"$robot_port\"" $twin_dir/robotconfig.xml 
    if [ $? -eq 0 ];then
        chmod -x $i
        kill -9 `ps  x |grep $i|grep -v grep |awk '{print $1}' `
        if [ $i = $robot_fullname ];then
            exit 0;
            echo "The robot already running;so it just be terminate!"
        fi
    fi
done
chmod +x $robot_fullname 
/home/king/starterobot.sh start
