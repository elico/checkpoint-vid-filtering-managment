#!/usr/bin/env bash

SCRIPT_ROOT=$(dirname $(readlink -f $0))

echo "dirname/readlink: ${SCRIPT_ROOT}"

## Debug
DB_PATH="${SCRIPT_ROOT}/system.db"
if [ -f "/flash/system.db" ];then
  DB_PATH="/flash/system.db"
fi

CLISH="${SCRIPT_ROOT}/fake_clish"
if [ -f "/pfrm2.0/bin/clish" ];then
  CLISH="/pfrm2.0/bin/clish"
fi

CUSTOM_APP_NAME="$1"

OPTION="$2"

case $2 in
	add)
		TMP_CLISH_FILENAME="$(date|md5sum |awk '{print $1}').clish"
		echo "set application application-name ${CUSTOM_APP_NAME} add url testing-check.com" |tee ${TMP_CLISH_FILENAME}
			
		${CLISH} -v -f "${TMP_CLISH_FILENAME}"
		rm -vf "${TMP_CLISH_FILENAME}"
	;;
	remove)
		TMP_CLISH_FILENAME="$(date|md5sum |awk '{print $1}').clish"
		echo "set application application-name ${CUSTOM_APP_NAME} remove url testing-check.com" |tee ${TMP_CLISH_FILENAME}
			
		${CLISH} -v -f "${TMP_CLISH_FILENAME}"
		rm -vf "${TMP_CLISH_FILENAME}"
	;;
        *)
            echo $"Usage: $0 list-name {add|remove}"
            exit 1
esac
