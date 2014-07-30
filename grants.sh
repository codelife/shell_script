#!/bin/bash
#Function export user privileges

expgrants()
{
  mysql -B -u'root' -N $@ -e "SELECT CONCAT(
    'SHOW GRANTS FOR ''', user, '''@''', host, ''';'
    ) AS query FROM mysql.user" | \
  mysql -u'root' $@ | \
  sed 's/\(GRANT .*\)/\1;/;s/^\(Grants for .*\)/-- \1 /;/--/{x;p;x;}'
}
expgrants > ./grants.sql
