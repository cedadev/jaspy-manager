#!/bin/bash

mod_base=/apps/jasmin/modulefiles


for mod_file in $(find _apps_jasmin_modulefiles -type f) ; do

  target_path=$mod_base/$(echo $mod_file | cut -d/ -f2-)
  target_dir=$(dirname $target_path)
  mod_fname=$(basename $target_path)

  echo $mod_file $target_dir
  mkdir -p $target_dir
  cp $mod_file $target_dir/

  echo "[INFO] Created: $target_path"

  version_file=${target_dir}/.version
  if [ ! -f $version_file ] ; then
    echo "#%Module1.0" > $version_file
    echo 'set ModulesVersion "'${mod_fname}'"' >> $version_file

    echo "[INFO] Created: $version_file"
  fi
done

