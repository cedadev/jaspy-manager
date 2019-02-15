# jaspy deployment

## Contents

The `deployment` directory contains tools to:

 1. Install a miniconda for a given python version: 
    `install-miniconda.sh <python_version>`

 2. Install a jaspy environment: 
    `install-jaspy-env.sh <jaspy_env_name>`

 3. Activate a jaspy environment: 
    `activate-jaspy-env.sh <jaspy_env_name>`

 4. Deactivate the current jaspy environment: 
    `deactivate-jaspy-env.sh`

Tools to actually create the recipe for each environment are:

 1. Create an environment and then generate a spec file from a YAML file: 
    `create-env-recipe.sh <yaml_file>`

Tools to manage conda channels:

 1. Create a local conda channel based on packages in a jaspy environment:
    `create-local-channel.sh <python_version>`
 

## Configuration

The deployment code depends on the following environment variables:

 - `JASPY_BASE_DIR`: 
   - Base directory for installation of JASPY conda environments
   - DEFAULT: `${HOME}/jaspy`

Information about the versions of Miniconda are available here:

 https://repo.continuum.io/miniconda/

We capture the URLs and the MD5 checksums of the miniconda scripts in:

 `.../etc/minicondas.json`
 
## Warning - installations are large!

Note that the software environments managed with `jaspy` are typically
many Gigabytes in size. The default is to install these under the 
`JASPY_BASE_DIR` (see above) inside your `$HOME` directory. Change this
setting if you wish to avoid installing into your `$HOME` directory.
