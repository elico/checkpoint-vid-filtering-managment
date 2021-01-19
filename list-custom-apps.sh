#!/usr/bin/env bash

SCRIPT_ROOT=$(dirname $(readlink -f $0))

echo "dirname/readlink: ${SCRIPT_ROOT}"

## Debug
DB_PATH="${SCRIPT_ROOT}/system.db"
if [ -f "/flash/system.db" ];then
  DB_PATH="/flash/system.db"
fi

echo "appUrl table structure:"
echo "#######################"

echo "pragma table_info('appUrl');"|sqlite3 ${DB_PATH}

echo "#######################"
echo

echo "customApp table structure:"
echo "#######################"

echo "pragma table_info('customApp');"|sqlite3 ${DB_PATH}
echo "#######################"
echo

echo "customApp: id(appId),list name(name), regexUrl"
echo "#######################"

echo "SELECT id,name,regexUrl FROM customApp;" |sqlite3 ${DB_PATH} |sed -e "s@|@ \t@g"
echo "#######################"

