#!/bin/bash

# Script to create a version of the final YAML environment file
env_name=$1

if [ ! $env_name ]; then
    echo "[ERROR] Please provide environment name as the only argument."
    exit
fi

env_dir=$(find environments-ceda-jaspy-envs/ -name $env_name -type d)

if [ ! -d "$env_dir" ]; then
    echo "[ERROR] Could not find a valid environment directory: ${env_dir}"
    exit
fi

initial_spec_file=${env_dir}/initial.yml

if [ ! -f "$initial_spec_file" ]; then
    echo "[ERROR] Could not find a valid initial spec file at: ${initial_spec_file}"
    exit
fi

final_spec_file=${env_dir}/final-spec.yml
echo "[INFO] Writing a final spec file: ${final_spec_file}"

echo "name: ${env_name}" > $final_spec_file
n_lines=$(wc -l $initial_spec_file | cut -d' ' -f1)
tail -$(( ${n_lines}-1 )) $initial_spec_file | grep -vP "(prefix:|/appx/jasmin/)" >> $final_spec_file
n_written_lines=$(wc -l $final_spec_file | cut -d' ' -f1)

if [ $n_lines -lt 100 ] || [ $(( $n_lines - $n_written_lines )) -gt 2 ]; then
    echo "[ERROR] The number of lines in the output file appears wrong:"
    echo "        Initial (${n_lines} lines): ${initial_spec_file}"
    echo "        Final   (${n_written_lines} lines): ${final_spec_file}"
    exit
fi

echo "[INFO] Wrote final spec file: ${final_spec_file}"
echo "[INFO] You may want to add it to the git repo and link the Jaspy help pages to it."

