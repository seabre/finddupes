#!/bin/bash

CREATE_TABLE="CREATE TABLE files (id INTEGER PRIMARY KEY, hash TEXT, location TEXT);"

TEMP_DB=/tmp/finddupes.$RANDOM.sqlite

sqlite3 $TEMP_DB "$CREATE_TABLE"

(find . -type f -print0 | xargs -0 md5sum)|while read line
do
  HASH=`echo $line | cut -f1 -d" "`
  LOCATION=`echo $line | cut -f2 -d" "`
  sqlite3 $TEMP_DB "INSERT INTO files (hash, location) values ('$HASH','$LOCATION');"
done

echo "The following files listed are the same:"

sqlite3 $TEMP_DB "SELECT hash, location FROM files WHERE hash NOT IN (SELECT hash FROM files GROUP BY hash HAVING ( COUNT(hash) = 1 ));"

rm -f $TEMP_DB
