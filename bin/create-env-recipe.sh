#!/bin/bash

SCRIPTDIR=$(dirname $0)
source $SCRIPTDIR/common.cfg

initial_yaml_path=$1

if [ ! $initial_yaml_path ] || [ ! -f $initial_yaml_path ]; then
    echo "[ERROR] Please provide valid YAML environment file as only argument."
    exit
fi

initial_yaml=$(basename $initial_yaml_path)

if [ $initial_yaml != 'initial.yml' ]; then
    echo "[ERROR] Input YAML file must be called: 'initial.yml'."
    exit
fi

spec_dir=$(dirname $initial_yaml_path)

# Get the env_name from the directory
env_name=$(basename $spec_dir)

# Get the python version from the next directory up
path_comps=$(echo $spec_dir | rev | cut -d/ -f2-3 | rev)
bin_dir=${JASPY_BASE_DIR}/jaspy/miniconda_envs/jas${path_comps}/bin

export PATH=${bin_dir}:$PATH

cmd="${bin_dir}/conda env create -n $env_name -f $initial_yaml_path"
echo "[INFO] Running: $cmd"
$cmd

if [ $? -ne 0 ]; then
    echo "[ERROR] 'conda env create' FAILED, so exiting."
    exit
fi

echo "[INFO] Created conda environment: $env_name"
source ${SCRIPTDIR}/activate-jaspy-env.sh $env_name

spec_file=${spec_dir}/_explicit.txt
echo "[INFO] Generating explicit spec file (excluding pip): $spec_file"
conda list --explicit > $spec_file 

urls_file=${spec_dir}/_urls.txt
echo "[INFO] Generating URLs file (excluding pip): $urls_file"
cat $spec_file | sed -n -e '/^@EXPLICIT/,$p' | grep -v @EXPLICIT | sed -e 's/^/    - /' > $urls_file

_pip_spec_file=${spec_dir}/_pip.txt
echo "[INFO] Generating pip component of yaml file: $_pip_spec_file"
cat $initial_yaml_path | grep -A1000 -P "\-\spip:" > $_pip_spec_file

pip_pkgs_file=${spec_dir}/pip.txt
echo "[INFO] Generating text file of packages to pip install: $pip_pkgs_file"
cat $initial_yaml_path | grep -A1000 -P "\-\spip:" | grep -vP "\-\spip:" | sed 's|\s*-\s*||g' > ${pip_pkgs_file}

spec_head=${spec_dir}/_head.yml
echo "[INFO] Generating header for explicit yaml file: $spec_head"
cat $initial_yaml_path | sed '/dependencies:/q' > $spec_head

complete_yaml=${spec_dir}/complete.yml
echo "[INFO] Generating complete explicit yaml file: $complete_yaml"
cat $spec_head $urls_file $pip_spec_file > $complete_yaml 

