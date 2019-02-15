# Check if script has been sourced
(return 2>/dev/null) && sourced=1 || sourced=0

if [ $sourced -ne 1 ]; then
    echo "[ERROR] Script only works if 'sourced'."
    echo "Usage:  source $0 <env_name>"
    exit
fi

SCRIPTDIR=$(dirname ${BASH_SOURCE[0]})
source ${SCRIPTDIR}/common.cfg

env_name=$1

ERR_MSG="[ERROR] Please provide valid conda environment name as the only argument."

if [ ! $env_name ] ; then
    echo $ERR_MSG
    exit
fi

yaml_path=$(get_env_path $env_name)

path_comps=$(echo $yaml_path | rev | cut -d/ -f2-3 | rev)
bin_dir=${JASPY_BASE_DIR}/jaspy/miniconda_envs/jas${path_comps}/bin
export PATH=${bin_dir}:$PATH

echo "[INFO] Activating conda environment: $env_name"
source activate $env_name

