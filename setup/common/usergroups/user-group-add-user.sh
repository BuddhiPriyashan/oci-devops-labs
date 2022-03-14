#!/bin/bash -f

if [ $# -lt 1 ]
then
  echo "The user group setup script requires one argument, the name of the group "
  echo "It will then add the currently defined user (in the USER_OCID) to that group"
  exit 1
fi

GROUP_NAME=$1
GROUP_NAME_CAPS=`bash ../settings/to-valid-name.sh $GROUP_NAME`
GROUP_OCID_NAME=GROUP_"$GROUP_NAME_CAPS"_OCID


export SETTINGS=$HOME/hk8sLabsSettings

if [ -f $SETTINGS ]
  then
    echo "Loading existing settings information"
    source $SETTINGS
  else 
    echo "No existing settings cannot continue"
    exit 10
fi

source $SETTINGS


if [ -z "$USER_OCID" ]
then
  echo "Cannot locate the users OCID, have you run the user-identity-setup.sh script ?"
  exit 1
fi

if [ -z "$USER_TYPE" ]
then
  echo "Cannot locate the users type, have you run the user-identity-setup.sh script ?"
  exit 2
fi

if [ -z "${!GROUP_OCID_NAME}" ]
then
  echo "Cannot find the saved OCID for group $GROUP_NAME"
  exit 3
fi

USERNAME=`oci iam user get --user-id $USER_OCID | jq -j '.data.name'` 

if [ "$USER_TYPE" != "local" ]
then
  echo "Sorry, user $USERNAME is not a local user and can't be added to a local group"
  echo "You will need to use the federated identity to setup a group containing the user"
  echo "and map that group to a local group"
  exit 4
fi

echo "Adding user $USERNAME to group $GROUP_NAME"

MEMBERSHIP_OCID=`oci iam group add-user --user-id $USER_OCID --group-id "${!GROUP_OCID_NAME}" | jq -r '.data.id'`

# The iam system doesn't seem to do anything with the membership OCID so when removing it just needs the group and user OCIDs
# So for now ignore this and there's no need to save it
