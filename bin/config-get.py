#!/usr/bin/env python

import os
import json
import sys
import argparse


def _find_config_file():

    config = 'etc/minicondas.json'

    while not os.path.isfile(config):
        config = '../{}'.format(config)

        if len(config) > 70:
            raise Exception('Cannot locate config file "etc/minicondas.json".')

    return config

    
def _get(sub_version, miniconda_version, attribute):

    config = _find_config_file()

    with open(config) as reader:
        data = json.load(reader)

    if miniconda_version == 'latest':

        _all_versions = [i.split('-')[1] for i in data['minicondas'][sub_version].keys()]
        m_start = 'm' + sub_version.replace('py', '').replace('r', '')[0]

        _av_ints = sorted([[int(i) for i in item.split('.')] for item in _all_versions])
        _all_versions = ['.'.join([str(item) for item in items]) for items in _av_ints] 

        miniconda_version = m_start + '-' + _all_versions[-1] 

    try:
        attr = data['minicondas'][sub_version][miniconda_version][attribute]
    except:
        print('Could not find {} attribute for python version: "{}"'.format(attribute, sub_version))

    return attr


if __name__ == '__main__':


    parser = argparse.ArgumentParser()
    parser.add_argument("sub_version", type=str, help="Python version")
    parser.add_argument("attribute", type=str, choices=['url', 'md5', 'short_id'],
                        help="Attribute")

    parser.add_argument('-m', '--miniconda-version', default='latest',
                        help='Add Miniconda version (or use "latest").',
                        type=str)
    args = parser.parse_args()
    print(_get(args.sub_version, args.miniconda_version, args.attribute))

