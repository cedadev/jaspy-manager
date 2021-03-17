# Developing Help documentation for JASPY on JASMIN

We are rolling out a new system for building and managing Python environments on 
JASMIN. There is a prototype Python 3.7 environment that you can try out which is 
mounted under `/apps/jasmin/` across all the main LOTUS and `jasmin-sci*` servers. 

You can enable (or "activate") the environment with the following lines:

```
export PATH=/apps/jasmin/jaspy/miniconda_envs/jaspy3.7/m3-4.5.11/bin:$PATH
conda activate jaspy3.7-m3-4.5.11-r20181219
```

After that set-up your default python (for the current session) will be python 3.7.****.

## Creating your own software environments "on top of" a JASPY environment

```
# Set path and activate conda environment
export PATH=/apps/jasmin/jaspy/miniconda_envs/jaspy3.7/m3-4.5.11/bin:$PATH
conda activate jaspy3.7-m3-4.5.11-r20181219

# Create your own virtualenv - you only do this once!
virtualenv --system-site-packages my-venv

# Activate your virtualenv
source my-venv/bin/activate

# Install some package into your virtualenv - only do this once!
pip install pytest

# Test we can import a package in the main conda env AND one in our own venv
python -c 'import matplotlib; import pytest'

# ...which would raise an exception if it couldn't find either package.
```

And then whenever you just want to use the environment, just do:

```
export PATH=/apps/jasmin/jaspy/miniconda_envs/jaspy3.7/m3-4.5.11/bin:$PATH
conda activate jaspy3.7-m3-4.5.11-r20181219
source my-py3-venv/bin/activate
```

Which ideally you would put in a setup script that you can "source" in your ".bashrc"
file or in any script that you want to pick up that environment.

## Other software environments

This approach enables us to provide multiple software environments simultaneously. It 
also allows the linking of environments to aliases, which you can use instead of the 
long environment name. 

### Environment aliases


### Tracking a consistent environment
 - use name, not alias

### Using the "current" environment
 - use the alias

### Using the "previous" environment

### Trying out the "next" environment

### Which environments are available?

 - use the command-line

