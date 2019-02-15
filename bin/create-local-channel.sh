#!/bin/bash

# 1. Creates a directory:
#    ${JASPY_BASE_DIR}/channels/${py_version}/linux-64/
#
# 2. Symlinks all "*.tar.bz" files from: ${JASPY_BASE_DIR}/${py_version}/pkgs/
#    into the above directory
#
# 3. Installs conda-build
# 4. Indexes the channel
# 5. Runs a test search
#

SCRIPTDIR=$(dirname $0)
source ${SCRIPTDIR}/common.cfg

env_name=$1

ERR_MSG="ERROR: Please provide the JASPY environment name as the only argument."

if [ ! $env_name ] ; then
    echo $ERR_MSG
    exit
fi

jaspy_version=$(echo $env_name | cut -d\- -f1)
miniconda_version=$(echo $env_name | cut -d\- -f2-3)

miniconda_env_dir=${JASPY_BASE_DIR}/jaspy/miniconda_envs/${jaspy_version}/${miniconda_version}
bin_dir=${miniconda_env_dir}/bin

if [ ! -d $bin_dir ] ; then
    echo "ERROR: Cannot find 'bin' directory at: $bin_dir"
    exit
fi

export PATH=${bin_dir}:$PATH

echo "Install conda-build"
cmd="${bin_dir}/conda install -y conda-build"
echo "Running: $cmd"
$cmd

echo "Create channels directory and symlink packages"
channels_dir=${JASPY_BASE_DIR}/jaspy/channels
channel_dir=${channels_dir}/${jaspy_version}/${miniconda_version}
noarch_dir=${channel_dir}/noarch
linux_64_dir=${channel_dir}/linux-64

echo "Create linux-64 dir: $linux_64_dir"
mkdir -p $linux_64_dir

pkg_dir=${miniconda_env_dir}/pkgs
cd $pkg_dir/
echo "Packages directory is: $pkg_dir"

count=0
for pkg in *.tar.bz2 ; do
    cd ${linux_64_dir}
    echo "Copying: $pkg"
    cp $pkg_dir/$pkg ./
    let count+=1
done

echo "Added $count packages to local channel." 

echo "Index the new channel: $linux_64_dir"
cmd="${bin_dir}/conda index $linux_64_dir"
echo "Running: $cmd"
$cmd
echo "NOTE: WE EXPECT AN ERROR ABOVE THIS LINE. IGNORE IT IF IT ENDS WITH: TypeError: Object of type 'method' is not JSON serializable"

echo "We need to re-run the index to make it work (see: https://github.com/conda/conda-build/issues/2776)...so re-index to fix..."
echo "Running: $cmd"
$cmd

echo "Test it with conda search."
cmd="${bin_dir}/conda search -c file://${channels_dir}/${jaspy_version}/${miniconda_version}/ --platform linux-64 --override-channels"
echo "Running: $cmd"
$cmd

