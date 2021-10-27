#!/bin/bash

SCRIPTDIR=$(dirname $0)
source ${SCRIPTDIR}/common.cfg

sub_version=$1
miniconda_version=$2
env_name=$3

ERR_MSG="[ERROR] Please provide arguments: <sub_version> <miniconda_version> <env_name>"

if [ ! $sub_version ] || [[ ! $sub_version =~ ^py[0-9]+\.[0-9]+$ ]] ; then
    echo $ERR_MSG
    exit
fi

if [ ! $miniconda_version ] || [[ ! $miniconda_version =~ ^m[0-9]+-[0-9]+.[0-9]+.[0-9]+ ]] ; then
    echo $ERR_MSG
    exit
fi

if [ ! $env_name ] ; then
    echo $ERR_MSG
    exit
fi

# Create directory and then copy the template into place
dr=${SCRIPTDIR}/../environments/${sub_version}/${miniconda_version}/${env_name}
echo "[INFO] Making directory: $dr"
mkdir -p $dr

initial_yaml=${dr}/initial.yml

cp ${SCRIPTDIR}/../templates/initial.yml.tmpl $initial_yaml
perl -p -i -w -e 's/__ENV_NAME__/'${env_name}'/g;' $initial_yaml

echo "[INFO] Environment file created, ready for editing: $initial_yaml"
