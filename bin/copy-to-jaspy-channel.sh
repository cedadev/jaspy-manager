#!/bin/bash

SCRIPTDIR=$(dirname $0)
source ${SCRIPTDIR}/common.cfg

PLATFORM="linux-64"

if [ ! $JASPY_SERVER_PATH ]; then
    echo "[ERROR]: JASPY_SERVER_PATH environment variable must be defined."
    exit
fi

if [ ! $JASPY_XFER_CACHE_DIR ]; then 
    echo "[ERROR]: JASPY_XFER_CACHE_DIR environment variable must be defined."
    exit
fi

mkdir -p ${JASPY_XFER_CACHE_DIR}

channel_urls_path=$1

if [ ! $channel_urls_path ] || [ ! -f $channel_urls_path ]; then
    echo "[ERROR]: Please provide valid URLs file as only argument."
    exit
fi

channels_url_fname=$(basename $channel_urls_path)
expected_name="channel-urls.txt"

if [ $channels_url_fname != $expected_name ]; then
    echo "[ERROR]: Input YAML file must be called: '${expected_name}'."
    exit
fi

spec_dir=$(dirname $channel_urls_path)

# Get the env_name from the directory
env_name=$(basename $spec_dir)

# Get the python version from the next directory up
path_comps=$(echo $spec_dir | rev | cut -d/ -f2-3 | rev)

jaspy_version=$(echo $env_name | cut -d\- -f1)
miniconda_version=$(echo $env_name | cut -d\- -f2-3)

miniconda_env_dir=${JASPY_BASE_DIR}/jaspy/miniconda_envs/jas${path_comps}
pkgs_dir=${miniconda_env_dir}/pkgs

echo "[INFO] Checking existence of all binaries before caching."

for binary in $(cat ${channel_urls_path} | grep http | sed 's|.*/||g'); do 
    pkg=${pkgs_dir}/$binary
    if [ ! -f $pkg ]; then
        echo "[ERROR] Package binary not found at: $pkg"
        echo "[ERROR] Fatal error so exiting."
        exit
    fi
done

target_dir="${JASPY_SERVER_PATH}/jas${path_comps}/${PLATFORM}"

remote_server=$(echo $target_dir | cut -d: -f1)
remote_dir=$(echo $target_dir | cut -d: -f2)

echo "[INFO] Making remote directory: ${remote_server}:${remote_dir}"
ssh ${remote_server} mkdir -p ${remote_dir}

echo "[INFO] Copying binaries to cache directory for transferral: ${JASPY_XFER_CACHE_DIR}"

for binary in $(cat ${channel_urls_path} | grep http | sed 's|.*/||g'); do
    pkg=${pkgs_dir}/$binary
    cp $pkg ${JASPY_XFER_CACHE_DIR}/
done

echo "[INFO] Copying binaries to remote jaspy channel server: ${JASPY_SERVER_PATH}"
cmd="rsync --size-only -v ${JASPY_XFER_CACHE_DIR}/* ${target_dir}/"
echo "[INFO] Running command: $cmd"
$cmd 

echo "[INFO] Removing temporary cache directory."
rm -fr ${JASPY_XFER_CACHE_DIR}

echo "[INFO] All binaries copied :-)"

