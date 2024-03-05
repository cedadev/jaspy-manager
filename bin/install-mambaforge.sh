#!/bin/bash

SCRIPTDIR=$(dirname $0)
source ${SCRIPTDIR}/common.cfg

sub_version=$1
mambaforge_version=$2

if [ ! $sub_version ] || [[ ! $sub_version =~ ^[pr][y]?[0-9]\.[0-9][0-9]?$ ]]; then
    echo "[ERROR] Please provide a valid sub-version in the form: py<n>.<m> or r<n>.<m>"
    exit
fi

# See links here:
# - https://github.com/conda-forge/miniforge#mambaforge

if [ "$mambaforge_version" == "" ]; then
    mambaforge_latest_url=https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh
else
    numeric_version=$(echo $mambaforge_version | sed 's/mf-//g')
    mambaforge_latest_url=https://github.com/conda-forge/miniforge/releases/download/${numeric_version}/Mambaforge-Linux-x86_64.sh
fi

fname=$(basename $mambaforge_latest_url)

jaspy_dir=${JASPY_BASE_DIR}/jaspy
src_dir=${jaspy_dir}/src
mkdir -p $src_dir

target=$src_dir/$fname

if [ ! -f $target ] ; then
   # Download new version
   echo "[INFO] Downloading: $mambaforge_latest_url"
   wget -O $target $mambaforge_latest_url
fi

found_mf_version=$(grep -a INSTALLER_VER= $target | cut -d\" -f2)
prefix=${JASPY_BASE_DIR}/jaspy/mambaforge_envs/jas${sub_version}/mf-${found_mf_version}

if [ -d $prefix ] ; then
    echo "[INFO] Miniconda base directory already exists at:"
    echo "       $prefix"
else
    echo "[INFO] Installing miniconda: $fname"
    chmod 750 $target

    mkdir -p $(dirname $prefix)
    $target -b -p $prefix 
fi

