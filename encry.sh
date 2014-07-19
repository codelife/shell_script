#!/bin/bash
root="/home/web/"
declare -a domain_list=(91coco.net)
for domain in $domain_list ;do 
    #������������ͬ��htm���ļ�Ϊhtml�ļ�
    for filename in `find ${root}${domain} -name "*.htm"`;do
        if [ ! -e ${filename}l ];then
            mv ${filename} ${filename}l
        fi
    done
    #�޸���������Ϊhtm�ļ�Ϊhtml��β�ļ�
    for filename in `find ${root}${domain} -name "*.htm*"`;do
        sed -i 's/\.htm\>/.html/' $filename
    done

    cd ${root}${domain}
    if [ $? -eq 0 ];then
        for filename in `find * -name "*.html" `;do
            if [ ! -e ${filename}.source ] ;then
                dir=${filename%/*}
                file=${filename##*/}
                if [ ! -d $dir ];then
                    dir='.'
                fi
                rm ${dir}/convert.php
                ln -s ~/bin/convert.php ${dir}
                url="http://www.$domain/$dir/convert.php?file=$file"
                wget -O /dev/zero $url
            fi
        done
    fi
done
