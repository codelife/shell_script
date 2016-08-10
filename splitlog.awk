BEGIN {
    FS="[\]\"\[]";
    #存放分割出文件的文件名
    filename = "filename.log"; 
}

{
if($0 !~ /^404/){
    #if(NR == 1)
    #{
    #    for(i=1; i<NF; i++)
    #    {
    #        print i $i;
    #    };
    #};
    #分割日期
    split($2,date,"[/:]");
    #过滤出需要的客户端spider
    if($8  ~ /googlebot|baiduspider/)
    {
        file= $8 "." date[3] "-" date[2] "-" date[1] ".log";
        printf("echo \"%s\" >> %s\n", $0, file);
        printf("echo \"%s\" >> %s\n", file, filename);
    }
}
}

END{
    #分割出的文件名去重,然后压缩
    printf( "echo \"cat %s |sort |uniq | xargs -I{}  gzip {}\"" , filename)
   }
