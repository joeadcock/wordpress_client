#!/bin/bash
service mysqld start

gunzip -c /tmp/dbdump.sql.gz | mysql \
  --user="$MYSQL_USER" \
  --password="$MYSQL_PASS" \
  --host="$MYSQL_SERVER" \
  --batch \
  "$MYSQL_DB"

rm /tmp/dbdump.sql.gz
