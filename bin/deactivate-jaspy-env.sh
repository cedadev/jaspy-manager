# Check if script has been sourced
(return 2>/dev/null) && sourced=1 || sourced=0

if [ $sourced -ne 1 ]; then
    echo "[ERROR] Script only works if 'sourced'."
    echo "Usage:  source $0"
    exit
fi

conda deactivate
