#!/bin/bash

SCRIPTDIR=$(dirname $0)
source ${SCRIPTDIR}/common.cfg

repo_url=$1

ERR_MSG="[ERROR] Please provide a valid repository URL as the argument."

if [ ! $repo_url ] || [[ ! $repo_url =~ ^http ]] ; then
    echo $ERR_MSG
    exit
fi

# Download the repository with GitHub
cd ${SCRIPTDIR}/../..

echo "[INFO] Cloning git repository: $repo_url"
git clone $repo_url
repo_name=$(basename $repo_url)

cd jaspy/

${SCRIPTDIR}/link-external-envs-repo.sh ../${repo_name}
