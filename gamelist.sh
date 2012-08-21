#!/bin/bash
list()
{
    for i in `ps x|grep sbin|grep -v grep |grep -v lobbserver|grep -v platform|awk '{print $5}'`
    do
        dirname=`dirname $i`
        #awk -F '"' '/GameName=/{printf("%-17s%-17s%-17s%-24s" ,$2,$4,$6,$10)};/channel id/{printf("%-10s",$4)}' $dirname/coreconfig.xml
        awk -F '"' '/GameName=/{printf("%s,%s,%s,%s," ,$2,$4,$6,$10)};/channel id/{printf("%s,",$4)}' $dirname/coreconfig.xml
        #awk -F '"' '/GameName=/{printf("%-17s%-17s%-17s%-24s" ,$2,$4,$6,$10)};/channel id/{printf("%-10s",$4)};/<\/server>/{printf("\n")}' $dirname/coreconfig.xml
        game_id=$(grep -i 'gameid=' $dirname/coreconfig.xml | awk '{i=1;while(i<=NF){if($i ~ /[Gg]ameID=/){split($i,p,"\"");print p[2];break}i++;}}')
        game_version=$(grep -i 'version=' $dirname/coreconfig.xml | awk '{i=1;while(i<=NF){if($i ~ /version=/){split($i,p,"\"");print p[2];break}i++;}}')
        game_downloadurl=$(grep -i 'autodownloadurl=' $dirname/coreconfig.xml | awk '{i=1;while(i<=NF){if($i ~ /AutoDownloadUrl=/){split($i,p,"\"");print p[2];break}i++;}}')
        game_gamename=$(grep -i 'gamename=' $dirname/coreconfig.xml | awk '{i=1;while(i<=NF){if($i ~ /[Gg]ame[Nn]ame=/){split($i,p,"\"");print p[2];break}i++;}}')
        game_catagory=$(grep -i 'Category=' $dirname/coreconfig.xml | awk '{i=1;while(i<=NF){if($i ~ /Category=/){split($i,p,"\"");print p[2];break}i++;}}')
        game_channelname=$(grep -i 'Category=' $dirname/coreconfig.xml | awk '{i=1;while(i<=NF){if($i ~ /[Cc]hannel[Nn]ame=/){split($i,p,"\"");print p[2];break}i++;}}')
        game_serveraddr=$(grep -i 'serveraddr=' $dirname/coreconfig.xml | awk '{i=1;while(i<=NF){if($i ~ /ServerAddr=/){split($i,p,"\"");print p[2];break}i++;}}')
        game_roomname=$(grep -i 'roomname=' $dirname/coreconfig.xml | awk '{i=1;while(i<=NF){if($i ~ /roomname=/){split($i,p,"\"");print p[2];break}i++;}}')
        #echo -e "\t$game_version \t $game_id  $game_downloadurl "
        printf "$game_version,$game_id,$game_downloadurl \n"
        #echo -e "$game_catagory \t  $game_gamename \t $game_roomname $game_version \t $game_id  $game_serveraddr $game_downloadurl "
    done
    return 0;
}
tempfile=$(mktemp)
list > $HOME/upt/gamelist 
exit
list >  $tempfile;
if [ -d $HOME/upt/ ];then
    sort -k1 -o $HOME/upt/gamelist $tempfile
else
    mkdir  $HOME/upt/
    sort -k1 -o $HOME/upt/gamelist $tempfile
fi
rm $tempfile
echo "All done $HOME/upt/gamelist ";
