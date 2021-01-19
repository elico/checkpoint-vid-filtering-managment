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

FW_CONFIG_RELOAD="${SCRIPT_ROOT}/fake_fw_configload"
if [ -f "/opt/fw1/bin/fw_configload" ];then
  FW_CONFIG_RELOAD="/opt/fw1/bin/fw_configload"
fi

CPSTAT="${SCRIPT_ROOT}/fake_cpstat"
if [ -f "/opt/fw1/bin/cpstat" ];then
  CPSTAT="/opt/fw1/bin/cpstat"
fi

CUSTOM_APP_NAME="YouTube-BlackList"
if [ ! -z "$1" ];then 
	CUSTOM_APP_NAME="$1"
fi

if [ ! -z "$2" ];then 
	VID="$2"
fi


SQL_TEMPLATE_REGEX_1=$(cat ${SCRIPT_ROOT}/sql-query-template-1.sql-in)
SQL_TEMPLATE_REGEX_2=$(cat ${SCRIPT_ROOT}/sql-query-template-2.sql-in)
SQL_TEMPLATE_REGEX_3=$(cat ${SCRIPT_ROOT}/sql-query-template-3.sql-in)


SQL_CHECK_IF_VID_EXISTS_TEMPLATE=$(cat ${SCRIPT_ROOT}/check-if-vid-exists-sql-template.sql-in)

ID_COUNTER=$(cat counter)
echo "Counter => ${ID_COUNTER}"
sleep 2

CUSTOM_APP_ID=$(echo "SELECT id,name FROM customApp;" |sqlite3 ${DB_PATH}|egrep "${CUSTOM_APP_NAME}$" |sed -e "s@|@ \t@g" | awk '{print $1}')
echo "YouTube-BlackList ID: ${YT_CUSTOM_APP_ID}"

#cat find-custom-appurl-values.sql-in |sed -e "s@###APP_ID###@${YT_CUSTOM_APP_ID}@g" |sqlite3 ${DB_PATH}

APPURL_VALUES=( $( echo "SELECT url FROM appUrl WHERE customApp_appUrls = ${CUSTOM_APP_ID};" |sqlite3 ${DB_PATH}) )

#echo "${APPURL_VALUES[@]}"|xargs -I{} echo {}

echo "Reading File"

TMP_CLISH_FILENAME="$(date|md5sum |awk '{print $1}').clish"
echo "set application application-name ${CUSTOM_APP_NAME} add url testing-check.com" |tee ${TMP_CLISH_FILENAME}

${CLISH} -v -f "${TMP_CLISH_FILENAME}"
rm -vf "${TMP_CLISH_FILENAME}"

echo "${VID}" |egrep "^([a-z0-9A-Z\_\-]+)$" >/dev/null
if [ "$?" -eq "0" ];then
	echo "Valid VID: ${VID}"
	# Check if exists..
	
	EXISTS=$(echo "${SQL_CHECK_IF_VID_EXISTS_TEMPLATE}" | sed -e "s@###VID###@${VID}@g"  -e "s@###APP_ID###@${YT_CUSTOM_APP_ID}@g" |sqlite3 ${DB_PATH} |wc -l)

	if [ "${EXISTS}" = "0" ];then
		echo "Doesn't exist, Updating"
		let "ID_COUNTER=ID_COUNTER+1"
		echo  "${ID_COUNTER}"
		echo -n "${ID_COUNTER}" > counter
		echo "${SQL_TEMPLATE_REGEX_1}" |sed -e "s@##OBJECT_ID##@${ID_COUNTER}@g" -e "s@##VID##@${VID}@g" -e "s@###APP_ID###@${YT_CUSTOM_APP_ID}@g"|sqlite3 ${DB_PATH}

                let "ID_COUNTER=ID_COUNTER+1"
                echo  "${ID_COUNTER}"
                echo -n "${ID_COUNTER}" > counter
                echo "${SQL_TEMPLATE_REGEX_2}" |sed -e "s@##OBJECT_ID##@${ID_COUNTER}@g" -e "s@##VID##@${VID}@g" -e "s@###APP_ID###@${YT_CUSTOM_APP_ID}@g"|sqlite3 ${DB_PATH}

                let "ID_COUNTER=ID_COUNTER+1"
                echo  "${ID_COUNTER}"
                echo -n "${ID_COUNTER}" > counter
                echo "${SQL_TEMPLATE_REGEX_3}" |sed -e "s@##OBJECT_ID##@${ID_COUNTER}@g" -e "s@##VID##@${VID}@g" -e "s@###APP_ID###@${YT_CUSTOM_APP_ID}@g"|sqlite3 ${DB_PATH}

	else
		echo "URL Pattern Already exists"
	fi

else
	echo "INVALID VID: ${VID}"
fi

echo "DONE"

echo "set application application-name ${CUSTOM_APP_NAME} remove url testing-check.com" |tee ${TMP_CLISH_FILENAME}

${CLISH} -v -f "${TMP_CLISH_FILENAME}"
rm -vf "${TMP_CLISH_FILENAME}"

echo "Applying settings"

${FW_CONFIG_RELOAD} && date && ${CPSTAT} fw |grep -i "install"

set +x
