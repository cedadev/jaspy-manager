#!/bin/bash

# Script to create a version of the YAML environment file with 
# pointing to the JASPY channels on the CEDA server
#
# 1. Read the packages file
# 2. Modify to provide the exact package+version+build for each package
# 3. Point to JASPY channel only

SCRIPTDIR=$(dirname $0)
source ${SCRIPTDIR}/common.cfg

PLATFORM=linux-64

packages_path=$1

if [ ! $packages_path ] || [ ! -f $packages_path ]; then
    echo "ERROR: Please provide valid packages file as only argument."
    exit
fi

packages_file=$(basename $packages_path)

if [ $packages_file != 'packages.txt' ]; then
    echo "ERROR: Input packages file must be called: 'packages.txt'."
    exit
fi


# FUNCTION to convert each package string into that required by conda
function get_pkg_string {
    pkg=$1
    version=$(echo $LINE | rev | awk -F'-' '{print $2}' | rev)
    build=$(echo $LINE | rev | awk -F'-' '{print $1}' | rev)
    count=$(awk -F"-" '{print NF-1}' <<< "${LINE}")
    package=$(echo $LINE | cut -d\- -f1-$(($count - 1)))
    pkg_string="${package}=${version}=${build}"
    echo $pkg_string
}


spec_dir=$(dirname $packages_path)

# Get the env_name from the directory
env_name=$(basename $spec_dir)

# Get the python version from the next directory up
sub_version=$(basename $(dirname $spec_dir))
miniconda_version=$(basename $spec_dir | cut -d/ -f2 | cut -d\- -f2-3)

# Write `final-spec.yml` environment file 
final_spec_file=${spec_dir}/final-spec.yml

# Write header
echo "name: $env_name" > $final_spec_file
echo "channels:" >> $final_spec_file
echo "  - http://dist.ceda.ac.uk/jaspy/jas${sub_version}/${miniconda_version}/linux-64/" >> $final_spec_file
echo "  - conda-forge" >> $final_spec_file
echo "dependencies:" >> $final_spec_file

pip_section=0

while read LINE; do

    if [[ "$LINE" =~ ^$ ]]; then
        continue
    fi

    if [[ "$LINE" =~ "Pip installs:" ]]; then
        pip_section=1
        echo "  - pip:" >> $final_spec_file
        continue
    fi 
    
    if [ $pip_section -eq 0 ]; then
        pkg_string=$(get_pkg_string ${LINE}) 
        echo "  - $pkg_string" >> $final_spec_file
    else
        echo "    - $LINE" >> $final_spec_file 
    fi

done < $packages_path

echo "Wrote explicit YAML file pointing at JASPY channel:"
echo "  ${final_spec_file}"

