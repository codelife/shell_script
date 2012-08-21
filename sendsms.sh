#!/bin/bash
all="$*"
msg=`echo $all |cut -d' ' -f2-`
/root/bin/fetion/fetion --mobile=13817200000 --pwd=sdsf@2011 --to=$1 --msg-utf8="$msg"
