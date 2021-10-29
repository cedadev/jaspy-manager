#!/bin/bash

# create-module-files.sh
# ----------------------
#
# 1. Installs package: environment-modules if "--install" used.
# 2. Detects all jaspy environments installed
# 3. Writes a modulefile for each jaspy environment installed
#

SCRIPTDIR=$(dirname $0)
source ${SCRIPTDIR}/common.cfg

arg1=$1

if [ "$arg1" ] && [ $arg1 == "--install" ]; then
    echo "[INFO] Install 'environment-modules' package"
    yum install -y environment-modules
fi

envs=()

for arg in $@; do
    if [ $arg == "--install" ]; then
        continue
    fi
    envs+=("$arg")
done

if [ ${#envs[@]} -eq 0 ]; then
    echo "[WARNING] Please provide environment name(s) at the command line."
    exit
fi

echo "[INFO] Set PREFIX and source the init script (in bash)"
PREFIX=/usr/share/Modules
source ${PREFIX}/init/bash

export MODULEPATH=/apps/modulefiles:$MODULEPATH

# Function: create_modulefile
#  - writes a module file for the environment directory provided
#  - splits the three-part environment name "X-env-<version>" into
#     two parts:  X-env  AND <version>
#  - Writes module files named as:
#      X-env/<version>
# 
function create_modulefile {
    _dir=$1
  
    if [ ! -d $_dir ] ; then
        echo "[ERROR] Invalid input for 'create_modulefile' function: $_dir"
        return
    fi 

    env_name=$(basename $_dir)
    jas_type=$(echo $env_name | cut -d. -f1 | sed 's/[0-9]*//g')
    jas_type_version=$(echo $env_name | cut -d- -f1 | sed 's/[a-zA-Z]*//g')
    revision=$(echo $env_name | cut -d- -f4)

    envs_dir=$(dirname $_dir)
    bin_dir=$(dirname $envs_dir)/bin
 
    mod_dir=${JASPY_MODULEFILE_BASE_DIR}/${jas_type}/${jas_type_version}
    mkdir -p $mod_dir

    mod_file=${mod_dir}/${revision}

    # Write the module file, pipe it through a perl regex so that all the 
    # additional flags/commands are captured in a string. If you don't do
    # this then Tcl will raise an error when you try to load the module.
    ${PREFIX}/bin/createmodule.py ${bin_dir}/activate $env_name | perl -p -e 's/^([^u][^n][^s][0-9a-zA-Z\-_]+)(\s+)(\w+)(\s+)(.+)$/\1\2\3\4"\5"/g;' | perl -p -e 's/unsetenv/\nunsetenv/g;' > $mod_file

    echo "[INFO] Wrote modulefile: $mod_file"
}


# Start main section
echo "[INFO] Loop through all requested environments and create module file..."

for indx in ${!envs[@]}; do 
    env_name=${envs[$indx]}

    echo "[INFO] Looking for env: $env_name"
    env_dir=$(find ${JASPY_BASE_DIR}/jaspy/miniconda_envs/jas*/*/envs -maxdepth 1 -type d -name ${env_name})
  
    if [ ! -d "$env_dir" ]; then
        echo "[WARNING] Cannot find environment directory for: ${env_name}"
    else
        echo "[INFO] Creating modulefile for: $env_dir"
        create_modulefile $env_dir
    fi
done

echo 
echo "-----------------------"
echo "Do we want to add following?"
echo
echo "#%Module -*- tcl -*-"
echo "##"
echo "## modulefile"
echo "##"
echo "proc ModulesHelp { } {"
echo ' puts stderr "\tAdds JASMIN Conda tools to your environment variables,"'
echo "}"
echo 
echo 'module-whatis " Adds JASMIN Conda tools to your environment variables"'

