#!/bin/bash

SCRIPTDIR=$(dirname $0)
source ${SCRIPTDIR}/common.cfg

env_name=$1

ERR_MSG="[ERROR] Please provide valid conda environment name as the only argument."

if [ ! $env_name ] ; then
    echo $ERR_MSG
    exit
fi

yaml_path=$(get_env_path $env_name)

path_comps=$(echo $yaml_path | rev | cut -d/ -f2-3 | rev)
sub_version=$(echo $path_comps | cut -d/ -f1 | cut -c3-)

bin_dir=${JASPY_BASE_DIR}/jaspy/miniconda_envs/jas${path_comps}/bin
export PATH=${bin_dir}:$PATH

echo "[INFO] Activating conda environment: $env_name"
source activate $env_name

tests_dir=environment/python${sub_version}
echo "[INFO] Running tests at: $tests_dir"
cd ${SCRIPTDIR}/test/

pytest $tests_dir

