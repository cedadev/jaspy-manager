#!/bin/bash

prefix=/usr/local/miniconda
basedir=/home/users/astephen/jaspy-notebook
prefix=${basedir}/miniconda

mkdir -p $basedir
cd $basedir/

bin_dir=${prefix}/bin
miniconda_url=https://repo.anaconda.com/miniconda/Miniconda3-py38_4.9.2-Linux-x86_64.sh
miniconda_sh=$(basename $miniconda_url)

if [ ! -f "$miniconda_sh" ]; then
    wget -O $miniconda_sh $miniconda_url
fi

if [ ! -d "${bin_dir}" ]; then
    bash $miniconda_sh -b -p $prefix
fi

${bin_dir}/conda install -y -c conda-forge mamba

spec_file_url=https://raw.githubusercontent.com/cedadev/ceda-jaspy-envs/master/environments/py3.8/m3-4.9.2/jaspy3.8-m3-4.9.2-r20211105/initial.yml
spec_file=$(basename $spec_file_url)

if [ ! -f "$spec_file" ] ; then
    wget -O $spec_file $spec_file_url
fi

env_name=$(head -1 $spec_file | cut -d: -f2 | sed 's/ //g')

${bin_dir}/mamba env create -f ${spec_file}

cd $prefix/envs/$env_name/

prefix=x86_64-conda-linux-gnu-
for exe in $prefix* ; do 
    if [ ! -e $exe ]; then 
        ln -s $exe ${exe/$prefix/}
    fi
done

echo
echo "[INFO] You can activate and use this environment with:"
echo "  export PATH=${bin_dir}:\$PATH"
echo "  source activate $env_name"

