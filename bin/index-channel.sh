#!/bin/bash

SCRIPTDIR=$(dirname $0)
source ${SCRIPTDIR}/common.cfg

channel_path=$1

if [ ! $channel_path ] ; then
    echo "[ERROR] Directory not found for channel: $channel_path"
    exit
fi

base=$(basename $channel_path)

if [ $base = "linux-64" ]; then
    echo "[WARN] Changing path to find real channel (removing 'linux-64')"
    channel_path=$(dirname $channel_path)
fi

path_comps=$(echo $channel_path | rev | cut -d/ -f1-2 | rev)
bin_dir=${JASPY_BASE_DIR}/jaspy/miniconda_envs/${path_comps}/bin
export PATH=${bin_dir}:$PATH

conda_build=${bin_dir}/conda-build

if [ ! -f $conda_build ]; then
    echo "[INFO] Installing 'conda-build' - required to index channel"
    ${bin_dir}/conda install conda-build
fi

echo "[INFO] Indexing channel: $channel_path"
${bin_dir}/conda index $channel_path

echo "[INFO] Indexing complete"
