#!/bin/bash

SCRIPTDIR=$(dirname $0)
source ${SCRIPTDIR}/common.cfg

env_name=$1
alias_name=$2


if [ ! $env_name ] ; then
    echo "[ERROR] Please provide conda environment name as first argument."
    exit
fi

if [ ! $alias_name ] ; then
    echo "[ERROR] Please provide alias name for conda environment as second argument."
    exit
fi

env_path=$(get_env_path $env_name)

path_comps=$(echo $env_path | rev | cut -d/ -f2-3 | rev)
envs_dir=${JASPY_BASE_DIR}/jaspy/miniconda_envs/jas${path_comps}/envs
bin_dir=${JASPY_BASE_DIR}/jaspy/miniconda_envs/jas${path_comps}/bin

cd $envs_dir
pushd $envs_dir

if [ ! -d $env_name ] ; then
    echo "[ERROR] Cannot locate conda environment: $env_name"
    exit
fi

ln -s $env_name $alias_name 
popd

echo "[INFO] Created alias with name: $alias_name"

echo "[INFO] You can activate and use this environment with:"
echo "  export PATH=${bin_dir}:\$PATH"
echo "  source activate $alias_name"

