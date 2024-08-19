#!/bin/bash

# create-module-files.sh
# ----------------------
#
# 1. Detects all jaspy environments installed
# 2. Writes a modulefile for each jaspy environment installed
#

SCRIPTDIR=$(dirname $0)
source ${SCRIPTDIR}/common.cfg

arg1=$1


## Older version of the script installed environment-modules package,
## which provided the createmodulefile.py script.  This script has been
## dropped from the package in Rocky9.  Now instead, a copy of the
## createmodulefile.py script is included in jaspy-manager.
#
# if [ "$arg1" ] && [ $arg1 == "--install" ]; then
#     echo "[INFO] Install 'environment-modules' package"
#     yum install -y environment-modules
#     shift
# fi

envs=("$@")

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
    revision=$(echo $env_name | rev | cut -d- -f1 | rev)

    envs_dir=$(dirname $_dir)
    main_dir=$(dirname $envs_dir)
    bin_dir=${main_dir}/bin
 
    mod_dir=${JASPY_MODULEFILE_BASE_DIR}/${jas_type}/${jas_type_version}
    mkdir -p $mod_dir

    mod_file=${mod_dir}/${revision}

    # Create a temporary script to wrap the activation lines into a single command
    tmp_activator=/tmp/tmp-jaspy-activator.sh
    echo "source ${bin_dir}/activate" > $tmp_activator
    echo "conda activate" >> $tmp_activator
    echo "conda activate $env_name" >> $tmp_activator
    chmod 750 $tmp_activator

    # Write the module file, pipe it through a perl regex so that all the 
    # additional flags/commands are captured in a string. If you don't do
    # this then Tcl will raise an error when you try to load the module.
# OLD - ${PREFIX}/bin/createmodule.py ${bin_dir}/activate $env_name

    simple_path=/usr/sbin:/usr/bin:/sbin:/bin    
    env -i PATH="$simple_path" \
        $SCRIPTDIR/createmodule.py $tmp_activator \
	| perl -p -e 's/^([^u][^n][^s][0-9a-zA-Z\-_]+)(\s+)(\w+)(\s+)(.+)$/\1\2\3\4"\5"/g;' \
	| perl -p -e 's/unsetenv/\nunsetenv/g;' > $mod_file
    
    # Remove temporary activator script
    rm -f $tmp_activator

    echo "[INFO] Wrote modulefile: $mod_file"
    if [ ! "$(grep condabin $mod_file)" ] ; then
        echo "[WARNING] Please add condabin to PATH manually in: $mod_file"
        echo "E.g..... to prepend-path       PATH    ${main_dir}/condabin - to existing line!"
    fi
}


# Start main section
echo "[INFO] Loop through all requested environments and create module file..."

for indx in ${!envs[@]}; do 
    env_name=${envs[$indx]}

    echo "[INFO] Looking for env: $env_name"
    env_dir=$(find ${JASPY_BASE_DIR}/jaspy/*envs/*/*/envs -maxdepth 1 -type d -name ${env_name})
  
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

