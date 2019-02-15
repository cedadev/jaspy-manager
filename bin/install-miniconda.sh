#!/bin/bash

SCRIPTDIR=$(dirname $0)
source ${SCRIPTDIR}/common.cfg

py_version=$1
miniconda_version=$2

if [ ! $py_version ] || [[ ! $py_version =~ ^py[0-9]\.[0-9]$ ]]; then
    echo "[ERROR] Please provide a valid python version in the form: py<n>.<m>"
    exit
fi

if [ ! $miniconda_version ]; then
    miniconda_version="latest"
fi

url=$(${SCRIPTDIR}/config-get.py -m $miniconda_version $py_version url)
fname=$(basename $url)
md5=$(${SCRIPTDIR}/config-get.py -m $miniconda_version $py_version md5)
short_id=$(${SCRIPTDIR}/config-get.py -m $miniconda_version $py_version short_id)

jaspy_dir=${JASPY_BASE_DIR}/jaspy
src_dir=${jaspy_dir}/src
mkdir -p $src_dir

target=$src_dir/$fname
download=1

if [ -f $target ] ; then
    # Get local md5
    local_md5=$(md5sum $target | cut -d' ' -f1)

    if [ $md5 == $local_md5 ]; then
        echo "[WARN] Up-to-date miniconda script already available locally."
        download=0
    fi
fi

if [ $download -eq 1 ] ; then
   # Download new version
   echo "[INFO] Found URL for python version: $py_version"
   echo "[INFO] Downloading: $url"
   wget -O $target $url
fi

# Check if already installed, if so: do nothing. 
prefix=${JASPY_BASE_DIR}/jaspy/miniconda_envs/jas${py_version}/${short_id}

if [ -d $prefix ] ; then
    echo "[INFO] Miniconda base directory already exists at:"
    echo "       $prefix"
else
    echo "[INFO] Installing miniconda: $fname"
    chmod 750 $target

    mkdir -p $(dirname $prefix)
    $target -b -p $prefix 
fi


