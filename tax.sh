#!/bin/bash
#gamedir=${1:-""}
#echo $gamedir
#查询当前正在运行的游戏的配置文件.可使用两个查询变量querystr1\querystr2.替换''中间的内容即可,如何只查询一个变量,另一个置空即可.
#如果文件中不包含querstr1和querstr2,输出文件名为红色.
querystr1='tax="1"'
querystr2='taxtype="0"'  # the two variables have must both setted
echo "The script will search all the  coreconfig.xml files."
#echo "The following files have both $querystr1 and $querystr2 "
SERVER=`ps x |awk '{print $(NF-1)}'|grep home |grep -v grep |grep -iv lobb |grep -iv platform` #|grep ${gamedir} #limit the process under some directory use this option.
for DIR  in $SERVER
do
    COREFILE=${DIR%/*}/coreconfig.xml
    GAMENAME=`awk -F'"' '/GameName/{print $4}' ${COREFILE}`
    #echo $GAMENAME
    grep -iq "${querystr1}" ${COREFILE} && n=$((n+1))
    grep -iq "${querystr2}" ${COREFILE} && n=$((n-1))
    case $n in
    "")
    #echo  "\033[43m \033[44m $COREFILE \033[0m"
    echo  "\033[41m $COREFILE \033[0m"
    ;;
    0)
    echo "$COREFILE "
    ;;
    1)
    echo "\033[33m $COREFILE  \t only  have $querystr1 \033[0m"
    ;;
    -1)
    echo "\033[34m $COREFILE  \t only have $querystr2 \033[0m"
    ;;
    esac
    unset n
done

