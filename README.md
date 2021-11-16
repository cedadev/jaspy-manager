# jaspy
Conda environments for JASMIN (and beyond)

## Quickstart

If you need a quick Python environment, try...

### Quickstart: Python3.8

```
git clone https://github.com/cedadev/jaspy-manager
cd jaspy-manager/

export JASPY_BASE_DIR=/usr/local/jaspy
./bin/install-miniconda.sh py3.7

./bin/add-envs-repo.sh https://github.com/cedadev/ceda-jaspy-envs

ENV_NAME=jaspy3.8-m3-4.9.2-r20211105
./bin/install-jaspy-env.sh $ENV_NAME

sub_version=$(echo $ENV_NAME | cut -d\- -f1)
miniconda_version=$(echo $ENV_NAME | cut -d\- -f2-3)

export PATH=$JASPY_BASE_DIR/jaspy/miniconda_envs/${sub_version}/${miniconda_version}/bin:$PATH
source activate $ENV_NAME

python -c 'import sys; print(sys.version)'
```

## Overview

This package provides the instructions and full specifications for a
collection of software environments built on top of the [conda](https://conda.io/)
package. The environments are primarily built to run on the [JASMIN](http://jasmin.ac.uk)
platform but they may be applicable for other uses.

## Why conda?

[Conda](https://conda.io/docs/user-guide/) is a package management system that has emerged 
from the Python community. It is an open source and runs on Windows, macOS and Linux. Conda 
can be used to install, run and update packages and their dependencies. It includes features 
to create, save, load and switch between environments on your local computer. It was created 
for Python programs, but it can package and distribute software for any language.

### Conda, Anaconda and Miniconda

The ecosystem of conda tools includes three main players. It is useful to understand the 
distinction between them:

 - **Conda**:	The package management system itself.
 - **Anaconda**:	A pre-selected set of (over 500) scientific software packages that can
	 be installed in a single (conda) environment.
 - **Miniconda**:	A basic installer that contains an entire Python installation and the
 	 conda package manager.

In this plan we are only concerned with conda and miniconda. It is necessary to start with 
miniconda in order to get a baseline python and conda installation. Once that is in place 
conda is available to create and manage multiple environments.

## Workflows

This diagram attempts to explain the workflow of jaspy:

![alt text](https://github.com/cedadev/jaspy-manager/blob/master/doc/images/jaspy_workflow.png "Jaspy workflow")

There are four workflows related to `jaspy`:

 1. **User** workflow:
   - Activate a `jaspy` environment
   - Use software in that environment 

 2. **Platform Administrator** workflow:
   - Install `jaspy`
   - Install environment(s)
   - Document usage of environment(s) for users

 3. **Environment Developer** workflow:
   - Install `jaspy`
   - Develop new environment(s)
   - Save the new environment(s)
   - Test the installation of the new environment(s)
   - Commit the new environments(s) to the repository

 4. **Jaspy Core Developer** workflow:
   - Install `jaspy`
   - Develop and improve the core framework.
   - Test and update the code.

### Workflow 1: User

Assuming that a Platform Administrator has installed `jaspy` then you can use it as
explained here. Get your settings as recommended by your administrator (which might be you):

**1. Clone the jaspy-manager repository**

```
git clone https://github.com/cedadev/jaspy-manager
cd jaspy-manager/
```

**2. Set your base directory to install jaspy (and the conda packages)**

This is where the conda environments and packages will be installed:

```
export JASPY_BASE_DIR=/usr/local/jaspy
```

**3. Install miniconda at the required version**

(Not really required but included for completeness)

```
./bin/install-miniconda.sh py3.8
```

**4. Add the CEDA repository of Jaspy environment recipes**

```
./bin/add-envs-repo.sh https://github.com/cedadev/ceda-jaspy-envs
```

**5. Install a Jaspy (conda) environment**

From the above repository we can see there is an environment called `jaspy3.8-m3-4.9.2-r20211105`:

```
ENV_NAME=jaspy3.8-m3-4.9.2-r20211105
./bin/install-jaspy-env.sh $ENV_NAME
```

**6. Activate and use the environment**

```
sub_version=$(echo $ENV_NAME | cut -d\- -f1)
miniconda_version=$(echo $ENV_NAME | cut -d\- -f2-3)

export PATH=$JASPY_BASE_DIR/jaspy/miniconda_envs/${sub_version}/${miniconda_version}/bin:$PATH
source activate $ENV_NAME

python -c 'import sys; print(sys.version)'
```

### Other features

List the available `jaspy` conda environments:

```
./bin/list-conda-envs.sh
```

## Versioning

There are different levels of versioning:

 1. Miniconda version, e.g.:
  - m2-4.5.4:    https://repo.continuum.io/miniconda/Miniconda2-4.5.4-Linux-x86_64.sh
  - m3-4.3.27.1: https://repo.continuum.io/miniconda/Miniconda3-4.3.27.1-Linux-x86_64.sh
  - m3-4.5.4:    https://repo.continuum.io/miniconda/Miniconda3-4.5.4-Linux-x86_64.sh
  - m3-4.6.14:   https://repo.continuum.io/miniconda/Miniconda3-4.6.14-Linux-x86_64.sh

 2. Python version:
  - python 2.7.15
  - python 3.6.2
  - python 3.7.3

 3. Versions of the `jaspy` environments themselves, e.g.:
  - jaspy2.7-m2-4.6.14-r20190715
  - jaspy3.7-m3-4.6.14-r20190627

To ensure reproducibility, the `jaspy` approach will involve creating a 
separate environment for each `python` and `miniconda` version as follows:

 - `${JASPY_BASE_DIR}/jas${PY_VERSION}/${MINICONDA_VERSION}/envs/${JASPY_ENV_NAME}`

E.g.:

 - `/apps/jasmin/jaspy/miniconda_envs/jaspy3.7/m3-4.6.14/envs/jaspy3.7-m3-4.6.14-r20190627`

### Note on reproducibility

Whilst this is a verbose and complex approach it is the most transparent way to ensure
that environments can be reproduced. However, we are aware that on any two systems there
might be subtle differences (for example in compilers and installed libraries) that might
lead to differences in the installation. Unfortunately, we do not have the resource to 
guarantee exact reproducibility.

Note that conda allows you to "pin" environments:

https://conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#building-identical-conda-environments

We use this approach but take it one step further by caching everything on our own server
to ensure that packages are not revoked from remote repositories.

## Set-up using module files

Users can activate a given `jaspy` environment using one of two methods:

 1. Source-activate:
   `source ${JASPY_BASE_DIR}/bin/activate <jaspy_env_id>`

 2. Module files:
   `module load jasmin/jaspy<sub_version>[/<jaspy_sub_version>]`

## FAQs

1. Why does jaspy insist on serving the binaries from its own channel?
 - Conda and its related ecosystem (`conda-forge` channel etc.,) provide a superb foundation for building and managing software environments. However, given the collaborative nature of the ecosystem there are dependencies that are out of our control, such as an update (or removal) to a package version, which can lead to problems.
  - In particular, a simple YAML environment description might resolve fine on one day but might not be repeatable the next day. A solution to this problem is to capture the exact environment in a set of binary files and cache them on our own server.
  - The jaspy channels are a place where we know that we can describe an exact environment independently of any perturbations that might be happening in other conda recipes and channels.
