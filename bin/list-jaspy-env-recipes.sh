#!/bin/bash

SCRIPTDIR=$(dirname $0)
source ${SCRIPTDIR}/common.cfg
cd ${SCRIPTDIR}/../

function list_envs {
    paths=$@

    for path in $paths; do
        if [[ $path =~ :$ ]]; then
            echo
            echo "    $(echo $path | sed 's|/| / |g')"
            echo
        else
            echo "      - $path"
        fi
    done
}

echo
echo "JASPY Environment recipes"
echo "-------------------------"
echo
echo "The following environment recipes are available to your JASPY installation."
echo "Note that these are recipes and the environments may not be installed yet."
echo
echo "Environments are listed under:"
echo "  - top-level directory / python version / miniconda version / environment name"

echo
echo "Core JASPY Environments:"
echo "========================"

list_envs $(ls environments/*/*)

if compgen -G "environments-*/*/*" > /dev/null ; then 

    echo 
    echo "JASPY Environments from external repositories:"
    echo "=============================================="

    list_envs $(ls environments-*/*/*)

fi

echo
