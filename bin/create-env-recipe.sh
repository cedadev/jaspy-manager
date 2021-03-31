#!/bin/bash

SCRIPTDIR=$(dirname $0)
source $SCRIPTDIR/common.cfg

initial_yaml_path=$1
DEBUG=$2

if [ ! $initial_yaml_path ] || [ ! -f $initial_yaml_path ]; then
    echo "[ERROR] Please provide valid YAML environment file as only argument."
    exit
fi

shopt -s nocasematch

if [ $DEBUG ] && [[ $DEBUG =~ debug ]]; then
    DEBUG=1
    echo "[INFO] Debug mode: ON"
else
    DEBUG=
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

cmd="${bin_dir}/mamba env create -n $env_name -f $initial_yaml_path"
if [ $DEBUG ]; then
    cmd="$cmd --verbose"
fi

echo "[INFO] Running: $cmd"
$cmd

if [ $? -ne 0 ]; then
    echo "[ERROR] 'conda env create' FAILED, so exiting."
    exit
fi

echo "[INFO] Created conda environment: $env_name"
export PATH=${bin_dir}:$PATH
source activate $env_name

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
cat $initial_yaml_path | grep -A1000 -P "\-\spip:" | grep -vP "\-\spip:" | sed 's|\s*-\s*||' > ${pip_pkgs_file}

spec_head=${spec_dir}/_head.yml
echo "[INFO] Generating header for explicit yaml file: $spec_head"
cat $initial_yaml_path | sed '/dependencies:/q' > $spec_head

complete_yaml=${spec_dir}/complete.yml
echo "[INFO] Generating complete explicit yaml file: $complete_yaml"
cat $spec_head $urls_file $pip_spec_file > $complete_yaml 

packages_file=${spec_dir}/packages.txt
echo "[INFO] Generating packages text file: $packages_file"
cat $urls_file | cut -d\- -f2- | xargs -L1 sh -c 'basename $1' _ | sort | sed 's/\.tar\.bz2//g' > $packages_file
echo "" >> $packages_file
echo "Pip installs:" >> $packages_file
cat $pip_pkgs_file | grep -v "#" >> $packages_file

cleaned_file=${spec_dir}/cleaned.txt
echo "[INFO] Generating cleaned initial yaml file: $cleaned_file"
sed -n '1,/# Pip installs/ p' $initial_yaml_path | grep -v "#" > $cleaned_file
echo "# Pip installs" >> $cleaned_file
cat $_pip_spec_file | grep -v "#" >> $cleaned_file

