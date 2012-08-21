#/bin/bash
password="test_passwd"
username="test_user"
useradd $username
expect -c "
        set timeout 5;
        spawn passwd test
        expect \"UNIX password:\" { send \"$password\r\";};
        sleep 2;
        expect \"UNIX password:\" { send \"$password\r\";};
        expect eof;
    interact
        "
