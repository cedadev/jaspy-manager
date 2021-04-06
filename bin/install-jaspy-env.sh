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

final_spec_fname="final-spec.yml"
pip_fname="pip.txt"

spec_file_dir=$(get_env_path $env_name)

if [ ! $spec_file_dir ] || [ ! -d $spec_file_dir ]; then
    echo "[ERROR] Cannot find spec file dir: $spec_file_dir"
    exit 1
fi

spec_file_path=${spec_file_dir}/${final_spec_fname}
pip_file_path=${spec_file_dir}/${pip_fname}

path_comps=$(echo $spec_file_dir | rev | cut -d/ -f2-3 | rev)

# Run miniconda installer: does nothing if already installed
py_version=$(echo $path_comps | cut -d/ -f1)
miniconda_version=$(echo $path_comps | cut -d/ -f2)

${SCRIPTDIR}/install-miniconda.sh ${py_version} ${miniconda_version}

if [ $? -ne 0 ]; then
    echo "[ERROR] Miniconda install failed so stopping."
    exit
fi

bin_dir=${JASPY_BASE_DIR}/jaspy/miniconda_envs/jas${path_comps}/bin
export PATH=${bin_dir}:$PATH

echo "[INFO] Creating new jaspy environment"

cmd="${bin_dir}/mamba env create -f ${spec_file_path}"
echo "[INFO] Running: $cmd"
$cmd

if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to create environment."
    exit
fi

echo "[INFO] Created conda environment: $env_name"

echo "[INFO] Creating symlinks to compilers"

env_bin_dir="$(dirname ${bin_dir})/envs/${env_name}/bin"
cd $env_bin_dir
prefix=x86_64-conda-linux-gnu-
for exe in $prefix* ; do ln -s $exe ${exe/$prefix/} ; done

echo
echo "[INFO] You can activate and use this environment with:"
echo "  export PATH=${bin_dir}:\$PATH"
echo "  source activate $env_name"

