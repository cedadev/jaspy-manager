#!/bin/bash

# clone-initial-env.sh
# --------------------
#
# - Takes either an environment name, directory or path to the `initial.yml`
#   file to identify the environment directory.
#   Creates a new environment directory using the name provided, copies
#   in the original `initial.yml` file and changes the top-line so it keeps
#   the name of the new environment.
#

SCRIPTDIR=$(dirname $0)
source ${SCRIPTDIR}/common.cfg

env_spec=$1
new_env=$2

INITIAL_FILE="initial.yml"

if [ ! $env_spec ] || [ ! $new_env ]; then
    echo "[ERROR] Must provide 2 arguments: <env_name> <new_env_name>"
    exit
fi


if [ -f $env_spec ]; then
    env_dir=$(dirname $env_spec)
else
    if [ -d $env_spec ]; then
        env_dir=$env_spec
    else
        env_dir=$(get_env_path $(basename $env_spec))
    fi
fi


if [ ! $env_dir ] || [ ! -d $env_dir ]; then 
    echo "[ERROR] Could not resolve environment specifier: $env_spec"
    echo "    Use one of:"
    echo "     - environment name"
    echo "     - environment directory"
    echo "     - path to environment $INITIAL_FILE file"
    exit
fi

base_dir=$(dirname $env_dir)
new_dir=${base_dir}/$new_env

echo "[INFO] Creating environment directory: ${new_dir}"
mkdir -p $new_dir

new_env_yaml=${new_dir}/${INITIAL_FILE}
echo "[INFO] Writing new YAML file: ${new_env_yaml}"

echo "name: ${new_env}" > $new_env_yaml
tail -n +2 ${env_dir}/${INITIAL_FILE} >>  ${new_env_yaml}

