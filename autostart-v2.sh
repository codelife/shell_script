#!/bin/bash
#必要条件，保证starter.sh和starterobot.sh 启动脚本在家目录
#所有需要启动的机器人可以被starterobot.sh 脚本所启动
#可能引发的问题:
#1.新添加游戏时.已给服务端添加了执行权限,但游戏配置还在修改中.游戏这段时间也会被启动
#2.删除游戏时,当游戏进程已经被杀死,但是执行权限还未去掉之间的这段时间游戏会被再次启动.
#按照标准规则添加和删除游戏,以上两条都不会发生.
#sleep 10
test -d $HOME/logs || mkdir $HOME/logs
tmpfile=$(mktemp)
~/starterobot.sh start
~/starter.sh start > $tmpfile
for server in `grep '\-D' $tmpfile |grep -iv 'phone\|voipserver' |awk '{print $2}'`
do
    game_server=$(basename $server)
    gamedir=$(dirname $server)
    corefile=$(find $gamedir -name "core.*" -and -mmin 3 |grep -v config |tail -1)
    game_zhname=$(grep -i 'gamename=' $gamedir/coreconfig.xml | awk '{i=1;while(i<=NF){if($i ~ /[Gg]ame[Nn]ame=/){split($i,p,"\"");print p[2];break}i++;}}')
    logname=$(date +%d-%-k-%M)$game_server
    echo -e "$game_zhname \t $gamedir\n\n" > $HOME/logs/$logname
    echo $server >> $logname
    if [[ -n $corefile ]];then
        getlog >> $HOME/logs/$logname
    fi
    serverid=$(grep -i "serveraddr=" $gamedir/coreconfig.xml  |grep -v grep | awk '{print $NF}' |awk -F'"' '{print $2}'| awk -F':' '{print $2}' )
    for robot in `ps x |grep  -i '/robot' |grep -v grep  |awk '{print $5}'`
    do
        echo $robot
        robotpid=$(ps x|grep $robot|grep -v grep |awk '{print $1}')
        robotdir=${robot%/*}
        grep -q "listenport=\"$serverid\"" $robotdir/robotconfig.xml
        if [ $? -eq 0 ];then
            kill -9 $robotpid
            sleep 2
            cd $robotdir && $robot -D
        fi
    done
done
rm $tmpfile
getlog()
{
    expect -c "
    set timeout 30;
    spawn gdb $server $corefile
    expect \"(gdb)\" {send \"bt\r\";}
    expect \"*0x*(gdb)\" {send \"quit\r\";}
    expect eof;" 
}
