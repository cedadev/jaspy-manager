# Making new Jaspy environments

## Overview

There are 2 different methods that we use for constructing a Jaspy environment.
The (1) _quick method_ pulls in the packages from Conda channels on the web.
The (2) _full method_ pulls in those packages, caches them on our server, and 
installs using only those files.

Method (2) is more reproducible, but we have found it is less reliable when we
try to build environments with many 100s of packages.

## Methods of creating and installing Jaspy environments
 
### 1. Quick method

The quick method includes the following steps:

1. Decide on a miniconda version - ensure it is recorded in our config file.
2. Download and install the miniconda version.
3. Connect the `ceda-jaspy-envs` repository to the local repo.
4. Create a name for the new environment.
5. Create an initial recipe of software packages for the new environment.
6. Run the `create-env-recipe.sh` script.
7. Run the `create-env-recipe-jaspy-channel.sh` script.
8. Push the changes to GitHub
9. On the server where the env needs installing, run: `install-jaspy-env.sh`

### 2. Full method

The full method is preferred, because it caches _all packages_ on our system, so that we can
definitely reproduce the same environment over time:

1. Decide on a miniconda version - ensure it is recorded in our config file.
2. Download and install the miniconda version.
3. Connect the `ceda-jaspy-envs` repository to the local repo.
4. Create a name for the new environment.
5. Create an initial recipe of software packages for the new environment.
6. Run the `create-env-recipe.sh` script.
7. Run the `create-env-recipe-jaspy-channel.sh` script.
8. Push the changes to GitHub
9. Copy the binaries of the packages to our Jaspy channel server, with `copy-to-jaspy-channel.sh`
10. On the Jaspy channel server, index the new packages
11. Adjust the `install-jaspy-env.sh` script to use the file containing our local URLs 
12. On the server where the env needs installing, run: `install-jaspy-env.sh` using our local URLs


## Notes (that need tidying)

These notes outline how the process has been run in the past...kept for reference.

```
mkdir /tmp/test
cd /tmp/test/

git clone https://github.com/cedadev/jaspy-manager
cd jaspy-manager/
export JASPY_BASE_DIR=/tmp/jaspy-base
mkdir -p $JASPY_BASE_DIR

# Install miniconda
./bin/install-miniconda.sh py3.7 m3-4.5.11

./bin/clone-initial-env.sh environments/py3.7/m3-4.5.11/isc-env-r20181009 test-env-r20190725
```

Test we can build an env with a file:

Create an `initial.yml` file.

Build the associated files and check it works:

```
./bin/create-env-recipe.sh environments-ceda-jaspy-envs/r3.6/jasr3.6-m3-4.9.2-r20211105/initial.yml

```

If it works, you can activate it with:

```
export PATH=$JASPY_BASE_DIR/jaspy/miniconda_envs/jaspy3.7/m3-4.5.11/bin:$PATH
source activate test-env-r20190725
```

Create URLs file that points to our own channel:

```
./bin/create-env-recipe-jaspy-channel.sh environments-ceda-jaspy-envs/r3.6/jasr3.6-m3-4.9.2-r20211105/packages.txt


```

Copy to dist server:

```
. ./setup-env.sh
./bin/copy-to-jaspy-channel.sh environments-ceda-jaspy-envs/r3.6/jasr3.6-m3-4.9.2-r20211105/_urls.txt


```

On dist server, index the channels. 

```
cd jaspy-manager/
./bin/index-channel.sh /datacentre/opshome/dist/htdocs/jaspy/jasr3.6

```


Install on JASMIN:

```
cd jaspy-manager/
./bin/install-jaspy-env jasr3.6-m3-4.9.2-r20211105
```
