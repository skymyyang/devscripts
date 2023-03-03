#!/bin/bash
platformINFO=$1

CM_NAMESPACE=$(echo ${platformINFO} | jq '."cm_namespace"' | sed 's/\"//g')
CM_NAME=$(echo ${platformINFO} | jq '."cm_name"' | sed 's/\"//g')
KEY0=$(echo ${platformINFO} | jq '."cm_infos"[0]."key"' | sed 's/\"//g')
VALUE0=$(echo ${platformINFO} | jq '."cm_infos"[0]."value"'| sed 's/\"//g')
KEY1=$(echo ${platformINFO} | jq '."cm_infos"[1]."key"' | sed 's/\"//g')
VALUE1=$(echo ${platformINFO} | jq '."cm_infos"[1]."value"' | sed 's/\"//g')
KEY2=$(echo ${platformINFO} | jq '."cm_infos"[2]."key"' | sed 's/\"//g')
VALUE2=$(echo ${platformINFO} | jq '."cm_infos"[2]."value"' | sed 's/\"//g')
KEY3=$(echo ${platformINFO} | jq '."cm_infos"[3]."key"' | sed 's/\"//g')
VALUE3=$(echo ${platformINFO} | jq '."cm_infos"[3]."value"' | sed 's/\"//g')

 if [ -e /usr/local/bin/kubectl ];then
	 kubectl -n $CM_NAMESPACE get configmap $CM_NAME >/dev/null 2>&1
	 if [ $? = 0 ];then
		 kubectl -n $CM_NAMESPACE delete configmap $CM_NAME >/dev/null  2>&1 && kubectl create configmap -n $CM_NAMESPACE $CM_NAME --from-literal=${KEY0}=${VALUE0} --from-literal=${KEY1}=${VALUE1} --from-literal=${KEY2}=${VALUE2} --from-literal=${KEY3}=${VALUE3} >/dev/null  2>&1
		 RES=$?
	else
		kubectl create configmap -n $CM_NAMESPACE $CM_NAME --from-literal=${KEY0}=${VALUE0} --from-literal=${KEY1}=${VALUE1} --from-literal=${KEY2}=${VALUE2} --from-literal=${KEY3}=${VALUE3} >/dev/null  2>&1
		RES=$?
	fi
# echo "kubectl create configmap -n $CM_NAMESPACE $CM_NAME --from-literal=${KEY0}=${VALUE0} --from-literal=${KEY1}=${VALUE1} --from-literal=${KEY2}=${VALUE2} --from-literal=${KEY3}=${VALUE3}"
 fi
echo "{\"status\":\"$RES\"}"