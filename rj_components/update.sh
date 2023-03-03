#!/bin/bash
# Requires jq to be installed
if [ -z "$1" ]
  then
    echo "usage: update-config-map.sh <namespace> <config map name> <config file to add>"
    exit 1
fi
if [ -z "$2" ]
  then
    echo "usage: update-config-map.sh <namespace> <config map name> <config file to add>"
    exit 1
fi
if [ -z "$3" ]
  then
    echo "usage: update-config-map.sh <namespace> <config map name> <config file to add>"
    exit 1
fi

CM_FILE=$(mktemp -d)/config-map.json
kubectl -n $1 get cm $2 -o json > $CM_FILE

DATA_FILES_DIR=$(mktemp -d)
files=$(cat $CM_FILE | jq '.data' | jq -r 'keys[]')
for k in $files; do
    name=".data[\"$k\"]"
    cat $CM_FILE | jq -r $name > $DATA_FILES_DIR/$k
    #sed -i "/##add_white/r $3" $DATA_FILES_DIR/$k;
    IFS='' && cat $3 | while read line; do sed -i "/##add_white_list_point/i \\  $line" $DATA_FILES_DIR/$k; done
done

echo cunfigmap: $CM_FILE tempdir: $DATA_FILES_DIR

kubectl -n $1 create configmap $2 --from-file $DATA_FILES_DIR -o yaml --dry-run=client |  kubectl apply -f -
mv $3 $3_used
echo Done
rm -rf $CM_FILE
echo removing temp dirs
rm -rf $DATA_FILES_DIR
