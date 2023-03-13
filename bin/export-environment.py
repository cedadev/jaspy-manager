#!/usr/bin/env python

import os
import sys
import re
import subprocess

"""
Does a fake 'conda env export', created by replacing the 'dependencies' section
of an actual 'conda env export' output with a list that is constructed by
looking at the contents of the conda-meta directory plus a filtered list of the
pip packages.

This is written to stdout.  In the event of it containing a different number 
of lines from the true 'conda env export' output, a warning is written to 
stderr.

This is to work around a problem where the actual 'conda env export' is 
wrongly labelling packages as pip packages instead of conda packages for some 
unknown reason.
"""

def get_conda_packages():
    """
    get a list of conda package specifications.
    also returns a set of just the names
    """

    packages = []
    names = set()    
    conda_meta_dir = os.path.normpath(os.path.join(
        os.path.dirname(sys.executable),
        "../conda-meta"))
    
    pat = "(.*)-([^-]+)-([^-]+)\.json"
    for fn in sorted(os.listdir(conda_meta_dir)):
        m = re.match(pat, fn)
        if not m:
            if fn not in ("history"):
                raise Exception(f"unparseable filename in conda meta dir: {fn}")
            continue
        name, version = m.group(1), f"{m.group(2)}={m.group(3)}"
        packages.append(f"{name}={version}")
        names.add(name)

    return packages, names


def get_pip_packages(ignores):
    """
    get a list of pip package specifications, ignoring:
    - everything with " @ file"
    - any names that match any item the 'ignores' collection case-insensitively
    """

    ignores = set(name.lower() for name in ignores)    
    pip_freeze_data = subprocess.check_output([sys.executable, '-m',
                                               'pip', 'freeze']).decode()
    pip_packages = []
    pat = "(.*)((?: @ |==).*)"
    for line in pip_freeze_data.split("\n"):
        m = re.match(pat, line)
        if not m:
            continue
        name, version_spec = m.groups()
        if " @ file" in version_spec or name.lower() in ignores:
            continue
        pip_packages.append(line)
    return pip_packages


def main():

    env_export_data = \
        subprocess.check_output(["conda", "env", "export"]).decode()

    packages, names = get_conda_packages()

    pip_packages = get_pip_packages(ignores=names)

    dependencies_str = "\n".join(
        [ f"  - {x}" for x in packages ]
        + [ "  - pip:"]
        + [ f"    - {x}" for x in pip_packages ])

    new_data = re.sub("(dependencies:).*?(\n[^\s])",
                      f"\\1\n{dependencies_str}\\2",
                      env_export_data, flags=re.DOTALL)

    print(new_data)

    if len(new_data.split("\n")) != len(env_export_data.split("\n")):
        sys.stderr.write("warning: different number of lines compared to "
                         "'conda env export' output")

main()
