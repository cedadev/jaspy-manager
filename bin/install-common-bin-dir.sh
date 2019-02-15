#!/bin/bash

SCRIPTDIR=$(dirname $0)
source ${SCRIPTDIR}/common.cfg

template_dir=../templates
bin_dir=${JASPY_BASE_DIR}/jaspy/bin
mkdir -p $bin_dir

tmpl=${template_dir}/activate-this-env.sh.tmpl
target=${bin_dir}/activate-this-env.sh

cp $tmpl $target
perl -p -i -w -e "s#__JASPY_BASE_DIR__#$JASPY_BASE_DIR#g;" $target
echo "Wrote: $target"
chmod 750 $target
