#!/bin/bash

SCRIPTDIR=$(dirname $0)
source ${SCRIPTDIR}/common.cfg

env_name=$1

ERR_MSG="[ERROR] Please provide valid conda environment name as the first argument."

if [ ! $env_name ] ; then
    echo $ERR_MSG
    exit
fi

# If environment is actually a file path (e.g. "../environments/py2.7/m2-4.5.11/cc-env-r20181008/")
# then just take the last component as the env name.
env_name=$(basename $env_name)

spec_fname="initial.yml"
#pip_fname="pip.txt"

spec_dir=$(get_env_path $env_name)

if [ ! $spec_dir ] || [ ! -d $spec_dir ]; then
    echo "[ERROR] Cannot find spec file dir: $spec_dir"
    exit 1
fi

spec_file_path=${spec_dir}/${spec_fname}
#pip_file_path=${spec_dir}/${pip_fname}

# Run mambaforge installer: does nothing if already installed
sub_version=$(basename $(dirname $(dirname $spec_dir)))
mambaforge_version=$(basename $spec_dir | cut -d/ -f2 | cut -d\- -f2- | rev | cut -d\- -f2- | rev)

${SCRIPTDIR}/install-mambaforge.sh ${sub_version} ${mambaforge_version}

if [ $? -ne 0 ]; then
    echo "[ERROR] Miniconda install failed so stopping."
    exit
fi

bin_dir=${JASPY_BASE_DIR}/jaspy/mambaforge_envs/jas${sub_version}/${mambaforge_version}/bin

export PATH=${bin_dir}:$PATH

echo "[INFO] Creating new jaspy environment"

cmd="mamba env create -f ${spec_file_path}"

echo "[INFO] Running: $cmd"
$cmd

if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to create environment."
    exit
fi

echo "[INFO] Created conda environment: $env_name"

#if [ -f "$pip_file_path" ]; then
#    echo "[INFO] Installing additional packages via PIP..."
#    source ${bin_dir}/activate 
#    conda activate $env_name
#    conda install --yes pip
#    pip install --upgrade pip
#    pip install -r ${pip_file_path} 
#else
#    echo "[INFO] No pip packages specified"
#fi

echo
echo "[INFO] You can activate and use this environment with:"
echo "  source ${bin_dir}/activate"
echo "  conda activate $env_name"


