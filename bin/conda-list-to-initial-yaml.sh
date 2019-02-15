#!/bin/bash

SRC=$1

if [ ! $SRC ]; then 
    echo "[ERROR] Please provide path to `conda list` output file."
    exit
fi

grep -v \# $SRC | sed 's/\s/=/g' | sed 's/==/=/g' | sed 's/==/=/g' | sed 's/==/=/g'| sed 's/==/=/g' | sed 's/==/=/g' | sed 's/==/=/g' | sed 's/==/=/g' | sed 's/=$//g' | sed 's/^/  - /g' 
