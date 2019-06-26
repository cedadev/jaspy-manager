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

DO_INSTALL=$1

if [ $DO_INSTALL ] && [ $DO_INSTALL == "--install" ]; then
    echo "Install 'environment-modules' package"
    yum install -y environment-modules
fi

echo "Set PREFIX and source the init script (in bash)"
PREFIX=/usr/share/Modules
source ${PREFIX}/init/bash

export MODULEPATH=/apps/modulefiles:$MODULEPATH

all_envs=$(find $JASPY_BASE_DIR/jaspy -name "envs" -type d)

echo "Define function"

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
    envs_dir=$(dirname $_dir)
    bin_dir=$(dirname $envs_dir)/bin
 
    mod_base=$(echo $env_name | cut -d- -f1-2)
    mod_version=$(echo $env_name | cut -d- -f3)

    mod_dir=${JASPY_MODULEFILE_BASE_DIR}/${mod_base}
    mkdir -p $mod_dir

    mod_file=${mod_dir}/${mod_version}

    # Write the module file, pipe it through a perl regex so that all the 
    # additional flags/commands are captured in a string. If you don't do
    # this then Tcl will raise an error when you try to load the module.
    ${PREFIX}/bin/createmodule.py ${bin_dir}/activate $env_name | perl -p -e 's/^([^u][^n][^s][0-9a-zA-Z\-_]+)(\s+)(\w+)(\s+)(.+)$/\1\2\3\4"\5"/g;' > $mod_file

    echo "Wrote modulefile: $mod_file"
}

echo "Loop through all known environments and create module file..."
for env_dir in $all_envs ; do
    for envt in $(ls $env_dir) ; do

        dr=${env_dir}/${envt}
        echo "Creating modulefiles for: $dr"
        create_modulefile $dr

    done
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
