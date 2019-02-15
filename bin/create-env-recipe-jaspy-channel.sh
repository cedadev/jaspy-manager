#!/bin/bash

# Script to create a version of the YAML environment file with 
# explicit URLs pointing to the JASPY channels on the CEDA server
#
# 1. Read the complete file
# 2. Modify URLs as follows:
#    - https://conda.anaconda.org/conda-forge/linux-64
#    - https://conda.anaconda.org/conda-forge/noarch
#    - https://repo.anaconda.com/pkgs/main
# 3. Put everything under: the JASPY channel URLs

SCRIPTDIR=$(dirname $0)
source ${SCRIPTDIR}/common.cfg

PLATFORM=linux-64

complete_yaml_path=$1

if [ ! $complete_yaml_path ] || [ ! -f $complete_yaml_path ]; then
    echo "ERROR: Please provide valid YAML environment file as only argument."
    exit
fi

complete_yaml=$(basename $complete_yaml_path)

if [ $complete_yaml != 'complete.yml' ]; then
    echo "ERROR: Input YAML file must be called: 'complete.yml'."
    exit
fi

spec_dir=$(dirname $complete_yaml_path)

# Get the env_name from the directory
env_name=$(basename $spec_dir)

# Get the python version from the next directory up
path_comps=$(echo $spec_dir | rev | cut -d/ -f2-3 | rev)

# Set base URL for packages in JASPY channel
url_base=${JASPY_CHANNEL_URL}/jas${path_comps}/${PLATFORM}

# Write `channel-urls.txt` environment file pointing to our URLs
jaspy_channel_urls=${spec_dir}/channel-urls.txt

cat ${complete_yaml_path} | grep http | sed 's|\s*-.*/|'$url_base'/|g' > ${jaspy_channel_urls}

echo "Wrote explicit YAML file pointing at JASPY channel:"
echo "  ${jaspy_channel_urls}"
