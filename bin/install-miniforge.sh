#!/bin/bash

SCRIPTDIR=$(dirname $0)
source ${SCRIPTDIR}/common.cfg

sub_version=$1
miniforge_version=$2

if [ ! $sub_version ] || [[ ! $sub_version =~ ^[pr][y]?[0-9]\.[0-9][0-9]?$ ]]; then
    echo "[ERROR] Please provide a valid sub-version in the form: py<n>.<m> or r<n>.<m>"
    exit
fi

# See links here:
# - https://github.com/conda-forge/miniforge#mambaforge

if [ "$miniforge_version" == "" ]; then
    miniforge_latest_url=https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
#Mambaforge-Linux-x86_64.sh
else
    numeric_version=$(echo $miniforge_version | sed 's/mf[0-9]-//g')
    miniforge_latest_url=https://github.com/conda-forge/miniforge/releases/download/${numeric_version}/Miniforge3-${numeric_version}-Linux-x86_64.sh
#https://github.com/conda-forge/miniforge/releases/download/${numeric_version}/Miniforge-Linux-x86_64.sh
#Mambaforge-Linux-x86_64.sh
fi

fname=$(basename $miniforge_latest_url)

jaspy_dir=${JASPY_BASE_DIR}/jaspy
src_dir=${jaspy_dir}/src
mkdir -p $src_dir

target=$src_dir/$fname

# Delete old version of file if exists (>2 weeks old)
age_in_seconds=$(($(date +%s) - $(stat --format=%Y /apps/jasmin/jaspy/src/Mambaforge-Linux-x86_64.sh)))
age_in_days=$(($age_in_seconds / 86400))
if [ -f $target ] && [ ${age_in_days} -gt 14 ]; then
    echo "[INFO] Deleting old version of file: $target"
    rm -f $target
fi

if [ ! -f $target ] ; then
   # Download new version
   echo "[INFO] Downloading: $miniforge_latest_url"
   wget -O $target $miniforge_latest_url
fi

found_mf_version=$(grep -a INSTALLER_VER= $target | cut -d\" -f2)
prefix=${JASPY_BASE_DIR}/jaspy/miniforge_envs/jas${sub_version}/${miniforge_version}

echo "target:            ${target}"
echo "miniforge_version: ${miniforge_version}"
echo "found_mf_version:  ${found_mf_version}"
echo "jaspy sub version: ${sub_version}"

if [ -d $prefix ] ; then
    echo "[INFO] Miniconda base directory already exists at:"
    echo "       $prefix"
else
    echo "[INFO] Installing miniconda: $fname"
    chmod 750 $target

    mkdir -p $(dirname $prefix)
    $target -b -p $prefix 
fi

