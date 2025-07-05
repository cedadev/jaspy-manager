#!/bin/bash
set -ex

# ==========================================================
# Downloads and builds a copy of esmf, in which the get_geom
# function is renamed.
#
# See https://github.com/cedadev/ceda-jaspy-envs/issues/138
# ==========================================================

version=8.8.1
install_dir=/appx/jasmin/jaspy/misc/esmf/$version
build_root=/var/tmp/esmf_build

#-----------------------------------------------------------

tarname=esmf-$version.tar.gz

if [ -e $install_dir ]
then
    echo "install dir $install_dir already exists"
    exit 1
fi

log_dir=$install_dir/install_logs
mkdir -p $log_dir
cp $0 $log_dir/

[ -d $build_root ] || mkdir -p $build_root
cd $build_root
build_dir=$build_root/esmf-$version

rm -fr $build_dir
wget -O $tarname https://github.com/esmf-org/esmf/archive/refs/tags/v$version.tar.gz
tar xfz $tarname
cd $build_dir

export ESMF_DIR=$build_dir
export ESMF_INSTALL_PREFIX=$install_dir
#export ESMF_BOPT=g  # uncomment for debuggable build - defaults to O

#-------------------------------------------------
# patch the source to rename the get_geom function
#-------------------------------------------------
src_files=$(grep -lrw get_geom .)
perl -p -i.orig -e 's,\bget_geom\b,esmf_get_geom,g' $src_files

mkdir -p $log_dir

make 2>&1 | tee $log_dir/make.log
[ $PIPESTATUS -eq 0 ] || exit $PIPESTATUS

make install 2>&1 | tee $log_dir/install.log
[ $PIPESTATUS -eq 0 ] || exit $PIPESTATUS
