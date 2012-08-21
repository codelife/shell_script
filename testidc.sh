#!/bin/bash
if [ -z $1 ];then
        echo "usage $0 un_gw"
        echo "input the un gw"
        read un_gw
else 
        un_gw=$1
fi
screen -dmS guangzhou ping             202.97.42.33 
screen -dmS beijing ping             202.97.0.23 
screen -dmS anhui ping             202.97.18.2      
screen -dmS shangdong ping             202.97.39.17 
screen -dmS hubei  ping            202.97.67.176 
screen -dmS shanxi  ping             202.97.65.0 
screen -dmS heilongjiang  ping             202.97.56.0 
screen -dmS guizhou ping             202.97.69.144 
screen -dmS guangxi ping             202.97.44.21 
screen -dmS guangdong ping             202.97.60.129  
screen -dmS shangxi ping             202.97.42.13    
screen -dmS ping.google  ping              www.google.com.hk 
screen -dmS ping.baidu  ping              www.baidu.com 
route add -host 218.104.78.2 gw $un_gw
route add -host 221.7.34.10 gw $un_gw
route add -host 218.104.111.114 gw $un_gw
route add -host 220.248.192.12 gw $un_gw
route add -host 202.99.192.66 gw $un_gw
route add -host 119.6.6.6 gw $un_gw
route add -host 202.99.96.68 gw $un_gw
route add -host 202.97.224.69 gw $un_gw
route add -host 61.168.242.255 gw $un_gw
screen -dmS anhui.un ping             218.104.78.2  
screen -dmS gansu.un ping             221.7.34.10  
screen -dmS hubei.un ping             218.104.111.114 
screen -dmS jiangxi.un ping             220.248.192.12 
screen -dmS shangxi.un ping             202.99.192.66 
screen -dmS sichuang.un ping             119.6.6.6 
screen -dmS tianjing.un ping             202.99.96.68 
screen -dmS heilongjiang.un  ping             202.97.224.69 
screen -dmS henan.un ping             61.168.242.255
screen -dmS shangdong.un ping             61.179.255.6 
