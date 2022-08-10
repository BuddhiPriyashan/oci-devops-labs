#!/bin/bash -f
SCRIPT_NAME=`basename $0`
CLUSTER_CONTEXT_NAME=one

if [ $# -gt 0 ]
then
  CLUSTER_CONTEXT_NAME=$1
  echo "$SCRIPT_NAME Operating on context name $CLUSTER_CONTEXT_NAME"
else
  echo "$SCRIPT_NAME Using default context name of $CLUSTER_CONTEXT_NAME"
fi

export SETTINGS=$HOME/hk8sLabsSettings

if [ -f $SETTINGS ]
  then
    echo "$SCRIPT_NAME Loading existing settings information"
    source $SETTINGS
  else 
    echo "$SCRIPT_NAME No existing settings cannot continue"
    exit 10
fi


bash ./osok-bundle-destroy.sh $CLUSTER_CONTEXT_NAME
RESP=$?
if [ "$RESP" -ne 0 ]
then
  echo "Error uninstalling Oracle Service Operator for Kubernetes, cannot continue"
  exit $RESP
fi
bash ./operator-lifecycle-manager-destroy.sh $CLUSTER_CONTEXT_NAME

RESP=$?
if [ "$RESP" -ne 0 ]
then
  echo "Error uninstalling lifecycle manager, cannot continue"
  exit $RESP
fi

bash ./remove-operator-sdk.sh
RESP=$?
if [ "$RESP" -ne 0 ]
then
  echo "Error removing operator, cannot continue"
  exit $RESP
fi
exit 0