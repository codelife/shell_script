#!/usr/bin/expect -f
if {$argc<3} {

            puts stderr "Usage:$argv0 hostip username password \n"
            #puts stderr "Usage:$argv0 hostip username password [timeout] [command].\n"
            #exit 1

}
set timeout 30
set IP     [lindex $argv 0]
set USER [lindex $argv 1]
set PASSWD {dsfSDF%$#GS54D}
#set PASSWD [lindex $argv 2]
set CMD     [lindex $argv 3]
spawn ssh -p 44405 $USER@$IP 
expect "(yes/no)?" {
send "yes\r"
sleep 1
expect "password:"
send "$PASSWD\r"
 } "password:" {send "$PASSWD\r"} "*host " {exit 1} "*$"{ send "ps x\r"}
interact
