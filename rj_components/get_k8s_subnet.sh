#!/bin/bash
#

function logJson(){
  echo "$@"
}
if [ -e /usr/bin/kubectl ];then
 podSubnet=$(kubectl cluster-info dump --namespaces kube-system | grep -m 1 cluster-cid | grep -E -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/[0-9]{1,3}")
 serviceSubnet=$(kubectl cluster-info dump --namespaces kube-system | grep -m 1 service-cluster-ip-range | grep -E -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/[0-9]{1,3}")
else
 podSubnet=""
 serviceSubnet=""

fi
RESSUBNET="\"podSubnet\": \"$podSubnet\",\"serviceSubnet\": \"$serviceSubnet\""
#echo $RESSUBNET
logJson "{$RESSUBNET}"