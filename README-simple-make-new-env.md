# Simple instructions to make a new Jaspy env

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

Reduce the new environment:

```
$ cat environments/py3.7/m3-4.5.11/test-env-r20190725/initial.yml
name: test-env-r20190725
channels:
  - conda-forge
  - defaults
dependencies:
  - numpy
  - pip:
    - ceda-cc
```

Run the create script:

```
bin/create-env-recipe.sh environments/py3.7/m3-4.5.11/test-env-r20190725/initial.yml
```

If it works, you can activate it with:

```
export PATH=$JASPY_BASE_DIR/jaspy/miniconda_envs/jaspy3.7/m3-4.5.11/bin:$PATH
source activate test-env-r20190725
```
