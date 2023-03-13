#!/usr/bin/env python3

description="""
Script to create an initial core_packages.yml file for a new release based
on the core_packages.yml and final-spec.yml files from the previous release.

Usage:   create-core-packages-file.py /path/to/previous_dir > core_packages.yml

where previous dir contains core_packages.yml and final-spec.yml files

(requires pyyaml)
"""

import re
import os
import sys
import argparse
import yaml


def get_opts():
    parser = argparse.ArgumentParser(description=description)
    parser.add_argument("dir",
                        help=("directory containing existing "
                              "core_packages.yml and final-spec.yml files"))
    return parser.parse_args()


def parse_final_spec(path):
    with open(path) as f:
        contents = yaml.safe_load(f)
    versions = {}
    pip_versions = {}
    for item in contents['dependencies']:
        if isinstance(item, str):
            name, version, _ = item.split('=')
            versions[name] = version
        elif isinstance(item, dict) and list(item) == ['pip']:
            for spec in item['pip']:
                name, version = spec.split('==')
                pip_versions[name] = version
        else:
            sys.stdout.write(f'ignoring {item}\n')
    return versions, pip_versions


def make_core_packages(prev_path, prev_vns, prev_pip_vns):
    vns_dict = None
    with open(prev_path) as f:
        for line in f:
            line = line.replace('\n', '')
            line_out = line
            if re.match('\s*#', line):
                pass
            elif line.endswith(':'):
                key = line.split(' ')[-1][:-1]
                if key == 'dependencies':
                    vns_dict = prev_vns
                elif key == 'pip':
                    vns_dict = prev_pip_vns
                else:
                    vns_dict = None
            elif vns_dict is not None:
                m = re.match('(\s*-\s+)(.*?)([<=>].*)?$', line)
                if m:
                    prefix = m.group(1)
                    name = m.group(2)
                    suffix = ''
                    if name in ['python', 'r-base']:
                        suffix += ' # USE LATEST VERSION?'
                    try:
                        line_out = f'{prefix}{name}>={vns_dict[name]}{suffix}'
                    except KeyError:
                        line_out = f'{prefix}{name} # CHECK VERSION'
            yield line_out
                

def main():        
    opts = get_opts()
    prev_core_packs = os.path.join(opts.dir, 'core_packages.yml')
    prev_final_spec = os.path.join(opts.dir, 'final-spec.yml')
    prev_vns, prev_pip_vns = parse_final_spec(prev_final_spec)
    for line in make_core_packages(prev_core_packs, prev_vns, prev_pip_vns):
        print(line)

    
main()
