#!/bin/bash
#存在的问题是如果一个目录中只有coreconfig.xml或者server程序的话,这个游戏依然运行不了,程序还会出错.
#1.exec 2 > /dev/null
#2.maxdepth=0|1;(待定)
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#$find . -name "$old_name" |xargs -i  mv {} {}.bak 
#$find . -name "$old_name" -exec mv {} {}.bak ;
#$find `find . -name coreconfig.xml  |xargs -i dirname {}` -perm -700 ! -type d  | xargs -i dirname {}
#find . -perm -700 ! -type d  | xargs -i mv {} {}.ljy.`date +%m.%d`.bak
#for GAMEDIR in `find `find $GAMEROOT -name coreconfig.xml|xargs -i dirname {}` -perm -700 ! -type d  | xargs -i dirname {}`
#find . -perm -700 ! -type d -iregex .*[0-9][0-9]\.[0-9][0-9]\.bak | xargs -i chmod -x {}
#new_version=$((old_version+1))
old_version=xx
new_version=xx
SERVER="/home/$USER/sbin/wzmj/newserver"
GAMEROOT="/home/$USER/sbin/wzmj/"
COUNT=`ps x |grep -v grep |grep -i ${SERVER##*/}|wc -l`
CHECK=0
find $GAMEROOT -perm -700 ! -type d
echo -e "All the game under the $GAMEROOT will be update\n"
read -p "Are you sure you want to changing theme all:(yes|no)" FINE;
#if [[ $FINE="yes" && -e $SERVER ]]
if [ -e $SERVER ] && [ $FINE="yes"]
then :;
else
    echo " make sure the SERVER is exist;"
    exit 0;
fi
find $GAMEROOT -perm -700 ! -type d  | xargs -i mv {} {}.ljy.`date +%m.%d`.bak
#for GAMEDIR in `find `find $GAMEROOT -name coreconfig.xml -exec dirname {} \;` -perm -700 ! -type d  | xargs -i dirname {}`
    for GAMEDIR in `find $GAMEROOT -iregex .*[0-9][0-9]\.[0-9][0-9]\.bak -perm -700 |xargs -i dirname {}` 
    do
        chmod +x $SERVER;
        cp $SERVER $GAMEDIR;
        if [  $? -eq 0 ] 
        then
            echo "copying $SERVER to  $GAMEDIR was successed"
        else
            echo "\033[45m  can not copy $SERVER to  $GAMEDIR, please check the permission\033[0m";
        fi
        if [ $old_version -eq $new_version ]
        then : ;
        else
            cp $GAMEDIR/coreconfig.xml $GAMEDIR/coreconfig.xml.`date +%m.%d`.bak
            echo "the $GAMEDIR/coreconfig.xml will be changed...."
            sed -i 's/version=\"'$old_version'\"/version=\"'$new_version'\"/' $GAMEDIR/coreconfig.xml
            sed -i 's/'$old_version'\.exe/'$new_version'\.exe/' $GAMEDIR/coreconfig.xml
            if [ $? -eq 0 ]
            then
                echo "the version has been changed to $new_version"
            else
                echo "the version has not been changed please check the files"
            fi
        fi
        find $GAMEDIR -iregex .*[0-9][0-9]\.[0-9][0-9]\.bak |xargs -i chmod -x {} 
        CHECK=$((CHECK+1));
    done
    if [ $COUNT -ne $CHECK ]
    then
        echo -e "\033[45m There is something wrong,the number of current running game is not equal the updated.\033[0m"
    else 
        echo "Everything is fine!!"
    fi
