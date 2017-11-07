#!/bin/bash
service mysqld start

gunzip -c /tmp/dbdump.sql.gz | \
  sed "s/localhost:8181/${WORDPRESS_HOST:-localhost:8181}/g" | \
  mysql \
    --user="$MYSQL_USER" \
    --password="$MYSQL_PASS" \
    --host="$MYSQL_SERVER" \
    --batch \
    "$MYSQL_DB"

rm /tmp/dbdump.sql.gz
