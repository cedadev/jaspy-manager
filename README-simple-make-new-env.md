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

```
exported.yml
```

Build it locally with:

```
./bin/install-jaspy-env.sh environments-ceda-jaspy-envs/py3.8/m3-4.9.2/jaspy3.8-m3-4.9.2-r20211105
```

If it works, you can activate it with:

```
export PATH=$JASPY_BASE_DIR/jaspy/miniconda_envs/jaspy3.7/m3-4.5.11/bin:$PATH
source activate test-env-r20190725
```

Copy to dist server:

```

```

Create final recipe using dist server URLs

```

```


Install on JASMIN:

```

```
