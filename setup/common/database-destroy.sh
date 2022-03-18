#!/bin/bash -f
export SETTINGS=$HOME/hk8sLabsSettings

if [ -f $SETTINGS ]
  then
    echo "Loading existing settings information"
    source $SETTINGS
  else 
    echo "No existing settings cannot continue"
    exit 10
fi

if [ -z "$AUTO_CONFIRM" ]
then
  export AUTO_CONFIRM=false
fi

if [ -z $DATABASE_REUSED ]
then
  echo "No reuse information for database safely cannot continue, you will have to destroy it manually"
  exit 0
fi

if [ $DATABASE_REUSED = true ]
then
  echo "You have been using a database that was not created by these scripts, you will need to destroy the database by hand"
  echo "and then remove DATABASE_REUSE and DATABASE_OCID from $SETTINGS "
  exit 0
fi

if [ -z $ATPDB_OCID ]
then 
  echo "No Database OCID information found, cannot destroy something that cannot be identifed"
  exit 3
fi

DBNAME=`oci db autonomous-database get --autonomous-database-id $ATPDB_OCID | jq -j '.data."display-name"'`
if [ "$AUTO_CONFIRM" = true ]
then
  REPLY="y"
  echo "Auto confirm is enabled, destroy database $DBNAME defaulting to $REPLY"
else
  read -p "Are you sure you want to destroy the database $DBNAMe and data it contains (y/n) ? " REPLY
fi

if [[ ! $REPLY =~ ^[Yy]$ ]]
then
  echo "Terminating database $DBNAME this may take a while"
  oci db autonomous-database delete --autonomous-database-id $ATPDB_OCID --force

  bash ./delete-from-saved-settings.sh ATPDB_OCID
  bash ./delete-from-saved-settings.sh DATABASE_REUSED
else
  echo "OK, not detroying database"
fi