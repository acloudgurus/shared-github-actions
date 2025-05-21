---
prev:
    text: Install
    link: '../'
next:
    false
---
zilvertonz/shared-github-actions/install/python
===========================================================

A GitHub action to Install Python Packages from a wheel and any extra dependencies specified

### Assumptions

+ Python version >=3.10 installed via [UV](https://docs.astral.sh/uv/). Current shared runner defaults to 3.10, and would require running `actions/setup-python` to specify a different version from 3.10. To install via UV in Github Actions, see example below.
+ An existing whl file to install from.
+ An existing pyproject.toml within the repository.
+ If using pipenv, An existing Pipfile is within the repository. 
+ If using Poetry, existing poetry configurations are set in pyproject.toml
+ If building and installing multiple python wheels across multiple python tomls, each comma-separated toml will be zipped with the corresponding comma-separated python wheel (e.g. `toml_parent_dir='path1/,path2/';whl_package_path='path1/dist/1.whl,path2/dist/2.whl`)

### Permissions

+ `contents: read`
  + Required to read contents

### Inputs

+ `additional_install_arguments`
  + String argument for additional installations (e.g. `-t package` ). Defaults to `""`.
  + type: `string`
+ `toml_parent_dir`
  + Parent directory which contains one or more tomls in subdirectories. Defaults to `.`
  + type: `string`
+ `environment_usage`
  + Setting for python package manager used for dependencies. Currently supported are `pip`, `poetry`, `pipenv`. Defaults to `pip`. `poetry` recommended.
  + type: `string`
+ `requirements_file`
  + Points to path of requirements.txt if existing for installation. Defaults to `""`
  + type: `string`
+ `additional_dependencies`
  + Space-separated names of extra dependencies to be installed. Defaults to `""`
  + type: `string`
+ `archived_package_path`
  + Points to path of Archive file to install.
  + type: `string`

### Outputs

None

### Using this action (default)

To use this action, make a workflow file in `.github/workflows` and use it in a job definition:
```
name: Install Python Packages

on:
  workflow_dispatch:

permissions:
  contents: read

jobs:
  BuildInstallPython:
    runs-on: MA-Analytics-Runner
    steps:
    - uses: actions/checkout@v4
    - name: Set up python 3.10
      id: py_setup
      run: |
        curl -LsSf https://astral.sh/uv/install.sh | sh
        uv python pin 3.10
    - name: Build Dependencies
      id: build_deps
      uses: zilvertonz/shared-github-actions/build/python@v1
      with:
        toml_parent_dir: 'module/aws/lambda_code,module/aws/glue_code'
        environment_usage: 'poetry'
    - name: Install Dependencies
      id: install_deps
      uses: zilvertonz/shared-github-actions/install/python@v1
      with:
        environment_usage: 'poetry'
        toml_parent_dir: 'module/aws/lambda_code,module/aws/glue_code'
        archived_package_path: ${{ steps.build_deps.outputs.python_whl_location }}
        additional_dependencies: 'numpy pandas pyarrow'
    - name: "Create Lamda Layer Package"
      id: lambda_layer_build
      uses: zilvertonz/shared-github-actions/install/python@hotfix-lambda-layer-building
      with:
        toml_parent_dir: "module/aws/lambda_layer/example_layer_lib"
        archived_package_path: ${{ steps.build_deps.outputs.python_whl_location }}
        environment_usage: "pip"
        additional_install_arguments: -t ./python

```

This workflow will run a job `BuildInstallPython` which will fail if toml_parent_dir is invalid, or environment used does not have requirements set for it. The step `Build Dependencies` will create a wheel file. The subsequent step `Install Dependencies` takes the output of `Build Dependencies` to pass the wheel file information for installation. Finally the `Create Lambda Layer Package` shows how to use this install action with the additional_install_arguments set to `-t {output}`, creating a usable environment for a lambda layer.
