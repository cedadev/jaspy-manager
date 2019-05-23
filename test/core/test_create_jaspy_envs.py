import os, shutil
import shlex, subprocess
dn = os.path.dirname

USER = os.environ.get('USER')
TEST_DIR = os.environ.get('JASPY_TEST_DIR', '/home/{}/jaspy-test'.format(USER))
TEST_DIR = '/apps/contrib'


THIS_DIR = dn(os.path.realpath(__file__))
SCRIPT_DIR = os.path.join(dn(dn(THIS_DIR)), 'deployment')


def _clear_base_dir(jaspy_base_dir):
    if os.path.isdir(jaspy_base_dir):
        shutil.rmtree(jaspy_base_dir)


def _run(cmd, jaspy_base_dir, use_func=False):
    """
    Run a command `cmd`, with JASPY_BASE_DIR environment variable set by
    `jaspy_base_dir`.

    :param cmd: Command string
    :param jaspy_base_dir: String to set as JASPY_BASE_DIR environment variable.
    :param use_func: Use other function in `subprocess` module instead of `subprocess.Popen` (default)
    :return: Response obje....
    """
    env = {'JASPY_BASE_DIR': jaspy_base_dir}
    args = shlex.split(cmd)
   
    print('Running command: {}'.format(cmd)) 
    if not use_func:
        sp = subprocess.Popen(args, env=env, cwd=SCRIPT_DIR) 
        sp.communicate()
    else:
        func = getattr(subprocess, use_func)
        sp = func(cmd, shell=True, executable='/bin/bash', env=env, cwd=SCRIPT_DIR) 

    return sp


def _common_create_jaspy_env(py_version, env_name, conda_forge_count):
    jaspy_base_dir = TEST_DIR
    miniconda_code = env_name.split('-', 1)[1].replace(env_name.split('-')[-1], '').strip('-')

    # Clear out base dir
    mc_base_dir = os.path.join(jaspy_base_dir, 'jaspy/miniconda_envs', 'jas{}'.format(py_version),
                                       miniconda_code) 
    _clear_base_dir(mc_base_dir)

    print('Download miniconda')
    cmd = '{} {}'.format(os.path.join(SCRIPT_DIR, 'install-miniconda.sh'), py_version)

    _run(cmd, jaspy_base_dir)
    assert(os.path.exists(os.path.join(jaspy_base_dir, 'jaspy/miniconda_envs', 'jas{}'.format(py_version))))

    print('Install a jaspy environment')
    cmd = '{} {}'.format(os.path.join(SCRIPT_DIR, 'install-jaspy-env.sh'), env_name)

    _run(cmd, jaspy_base_dir) 
    assert(os.path.exists(os.path.join(jaspy_base_dir, 'jaspy/miniconda_envs', 'jas{}'.format(py_version), 
                                       miniconda_code, 'envs', env_name)))

    # Test by activating and listing contents of current environment
    bin_dir = os.path.join(jaspy_base_dir, py_version, 'bin')
    cmd = 'export PATH={}:$PATH ; conda activate {} ; conda list | grep conda-forge | wc -l'.format(bin_dir, env_name)
 
    resp = _run(cmd, jaspy_base_dir, use_func='check_output') 
    assert(resp.decode("utf-8").strip() == str(conda_forge_count))


def OFFtest_create_jaspy_env_py27():
    py_version = 'py2.7'
    env_name = 'jaspy2.7-m2-4.5.4-rc4'
    conda_forge_count = 350

    _common_create_jaspy_env(py_version, env_name, conda_forge_count)


def test_create_jaspy_env_py36():
    py_version = 'py3.6'
    env_name = 'jaspy3.6-m3-4.5.4-rc3'
    conda_forge_count = 347

    _common_create_jaspy_env(py_version, env_name, conda_forge_count)
