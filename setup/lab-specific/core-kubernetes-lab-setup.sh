#!/bin/bash -f

if [ -f ./script-locations.sh ]
then
  source ./script-locations.sh
else
  echo "Unable to locate the script-locations.sh file, are you running in the right directory ?"
  exit -1
fi

echo "Welcome the the core kubernetes specific lab setup script."
read -p "Are you running in a free trial account, or in an account where you have full administrator rights ?" REPLY
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
  echo "Unfortunately if you are not an adminitrator or in a free trial account this script cannot automatically"
  echo "configure your environment. You can probabaly still run the labs however. Please follow the instructions"
  echo "in the lab documentation to manually configure your environment"
  exit 1
fi
echo "This script will:"
echo "  Download the step certificate tools and create a self signed root cert"
echo "  Gather basic information (your initials)"
echo "  Create a compartment for you to work in"
echo "  Create and configure a database for you to use"
echo "  Create a Kubernetes cluster"
echo "  Create an auth token to use when talking to OCIR"
echo "  Create OCIR repos for the storefront and stockmanager microservices"
echo "  Build, package and upload to OCIR the images you will use"
echo "  Setup YAML files for image locations"
echo ""
echo "This script can in most cases automatically apply a sensible default answer to questions (for example the name used"
echo "for the database or the compartment location). Alternatively you can specify answers manually which would let you"
echo "chose customise names and locations."
echo "Note that for some inputs (e.g. entering your initials) it is not possible to make an automatic guess, in those cases"
echo "you will still be prompted for input."

read -p "Do you want to use the automatic defaults ?" REPLY
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
   export AUTO_CONFIRM=false
else
   export AUTO_CONFIRM=true
fi

SAVED_PWD=`pwd`

cd $MODULES_DIR

bash ./core-kubernetes-setup-module.sh
RESP=$?
if ( "$RESP" -ne 0 ]
then
  echo "Core kubernetes setup module returned an error, unable to continue"
  exit $RESP
fi

exit 0