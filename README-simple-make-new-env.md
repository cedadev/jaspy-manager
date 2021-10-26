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

On archman2, index the channels. 

```


```


Install on JASMIN:

```

```
