import os
import pytest

import subprocess as sp
import shlex
SAMPLE_DATA_DIR = None
TEMPLATES_DIR = './test_templates'

def _run(cmd):
    bytes = sp.check_output(cmd, shell=True, executable='/bin/bash', stderr=sp.STDOUT)
    return bytes.decode('utf-8').replace('\n', '')


def _setup():
    import iris_sample_data as isd
    _sample_data_dir = os.path.join(os.path.dirname(isd.__file__), 'sample_data')
    global SAMPLE_DATA_DIR
    SAMPLE_DATA_DIR = _sample_data_dir 

def _fpath(fname):
    return os.path.join(SAMPLE_DATA_DIR, fname)


def _check_output(cmd, match):
    resp = _run(cmd)
    assert(match in resp)


def test_cdo_infov():
    cmd = 'cdo infov {} | grep air_temperature'.format(_fpath('A1B_north_america.nc'))
    _check_output(cmd, 'Processed 435120 values from 1 variable over 240 timesteps')


def test_ncdump():
    cmd = 'ncdump -h {}'.format(_fpath('A1B_north_america.nc'))
    _check_output(cmd, 'Data from Met Office Unified Model 6.05')


def test_nco_ncks_help():
    cmd = 'ncks --help'
    _check_output(cmd, 'cheatsheet')

#@pytest.mark.xfail
def test_nco_ncks_subset(tmpdir):
    fin = _fpath('A1B_north_america.nc')
    fout = tmpdir.mkdir("test-outputs").join('fout.nc')
    _run('ncks -d latitude,,,20 -d longitude,,,20 -d time,,,6 {} {}'.format(
                   fin, fout))

    # Check ncdump output
    resp = _run('ncdump -h {}'.format(fout)) 
    assert('latitude = 2 ;' in resp)
    assert('longitude = 3 ;' in resp)

def test_r_netcdf(tmpdir):
    p = tmpdir.mkdir("r-tests").join("test.R")
    nc_path = _fpath('A1B_north_america.nc')
    lines = ('library(ncdf4)\n',
             'nc <- nc_open(\'{}\')\n'.format(nc_path),
             'print(nc)\n')

    for line in lines:
        p.write(line, mode='a')

    cmd = 'R -f {}'.format(p)
    _check_output(cmd, 'forecast_reference_time')

def test_ncl_write_netcdf(tmpdir):
    p = tmpdir.mkdir("ncl-tests").join('write_netcdf.ncl')
    ncl_tmpl = os.path.join(TEMPLATES_DIR, 'ncl', 'write_netcdf.ncl')
    
    fout = os.path.join(tmpdir, 'ncl-test.nc')
    lines = [line.replace('__OUTPUT_PATH__', fout) for line in 
                                           open(ncl_tmpl).readlines()]

    for line in lines:
        p.write(line, mode='a')

    cmd = 'ncl {}'.format(p)
    _run(cmd)
    assert(os.path.isfile(fout))

    # Check ncdump output
    resp = _run('ncdump -v time {}'.format(fout))
    assert('time = 1, 2, 3, 4, 5 ;' in resp)


